// Emplacement cible : lib/views/historique/historique_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/course_model.dart';
import '../../routes/app_routes.dart';
import '../../store/course_store.dart';
import 'historique_filtres.dart';
import 'widgets/etat_vide_historique.dart';
import 'widgets/historique_card.dart';
import 'widgets/historique_filtres_sheet.dart';

/// Liste les courses clôturées (historique / preuves de livraison),
/// avec recherche client persistante et filtres avancés (réf. colis,
/// plage de dates) via bottom sheet.
class HistoriqueView extends StatefulWidget {
  const HistoriqueView({super.key});

  @override
  State<HistoriqueView> createState() => _HistoriqueViewState();
}

class _HistoriqueViewState extends State<HistoriqueView> {
  final _clientController = TextEditingController();
  HistoriqueFiltres _filtres = const HistoriqueFiltres();

  @override
  void dispose() {
    _clientController.dispose();
    super.dispose();
  }

  void _ouvrirCourse(CourseModel course) {
    context.push(AppRoutes.historiqueDetailsPath(course.id));
  }

  Future<void> _ouvrirFiltres() async {
    final resultat = await showModalBottomSheet<HistoriqueFiltres>(
      context: context,
      isScrollControlled: true,
      builder: (_) => HistoriqueFiltresSheet(filtresInitiaux: _filtres),
    );
    if (resultat != null) {
      setState(() => _filtres = resultat);
    }
  }

  List<CourseModel> _filtrer(List<CourseModel> courses) {
    final recherche = _clientController.text.trim().toLowerCase();

    return courses.where((c) {
      if (c.status != CourseStatus.cloturee) return false;
      if (recherche.isNotEmpty && !c.client.toLowerCase().contains(recherche)) {
        return false;
      }
      return _filtres.correspondA(c);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _clientController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un client',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _clientController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => _clientController.clear()),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton.outlined(
                      onPressed: _ouvrirFiltres,
                      icon: const Icon(Icons.tune),
                      tooltip: 'Filtres',
                    ),
                    if (_filtres.estActif)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: CourseStore.instance,
              builder: (context, _) {
                final coursesFiltrees = _filtrer(CourseStore.instance.courses);

                if (coursesFiltrees.isEmpty) {
                  final filtresActifs =
                      _clientController.text.trim().isNotEmpty || _filtres.estActif;
                  return EtatVideHistorique(filtresActifs: filtresActifs);
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: coursesFiltrees.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final course = coursesFiltrees[index];
                    return HistoriqueCard(
                      course: course,
                      onTap: () => _ouvrirCourse(course),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}