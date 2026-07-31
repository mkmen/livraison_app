import 'package:flutter/material.dart';

import '../../models/course_model.dart';
import '../../services/facturation_service.dart';
import '../../store/course_store.dart';
import 'widgets/selecteur_periode.dart';

/// Sélection d'une période (mois ou plage libre) pour afficher un
/// résumé d'activité (nombre de courses, chiffre d'affaires) et
/// générer le PDF de récap correspondant.
class RecapMensuelView extends StatefulWidget {
  const RecapMensuelView({super.key});

  @override
  State<RecapMensuelView> createState() => _RecapMensuelViewState();
}

class _RecapMensuelViewState extends State<RecapMensuelView> {
  DateTime? _debut;
  DateTime? _fin;
  bool _generationEnCours = false;

  List<CourseModel> get _coursesSurPeriode {
    final debut = _debut;
    final fin = _fin;
    if (debut == null || fin == null) return const [];
    return FacturationService.coursesSurPeriode(
      toutesLesCourses: CourseStore.instance.courses,
      debut: debut,
      fin: fin,
    );
  }

  Future<void> _genererRecap(List<CourseModel> courses) async {
    final debut = _debut;
    final fin = _fin;
    if (debut == null || fin == null) return;

    setState(() => _generationEnCours = true);
    try {
      await FacturationService.genererEtPartagerRecap(debut: debut, fin: fin, courses: courses);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de la génération : $e')),
      );
    } finally {
      if (mounted) setState(() => _generationEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final courses = _coursesSurPeriode;
    final coursesFacturees = courses.where((c) => c.montant != null).toList();
    final total = coursesFacturees.fold<double>(0, (somme, c) => somme + (c.montant ?? 0));

    return Scaffold(
      appBar: AppBar(title: const Text('Récapitulatif mensuel')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SelecteurPeriode(
            onChanged: (debut, fin) => setState(() {
              _debut = debut;
              _fin = fin;
            }),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _StatTile(label: 'Courses', valeur: '${courses.length}')),
              const SizedBox(width: 12),
              Expanded(child: _StatTile(label: 'Facturées', valeur: '${coursesFacturees.length}')),
              const SizedBox(width: 12),
              Expanded(child: _StatTile(label: 'CA', valeur: '${total.toStringAsFixed(2)} €')),
            ],
          ),
          if (courses.length > coursesFacturees.length)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                '${courses.length - coursesFacturees.length} course(s) sans montant renseigné.',
                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: (courses.isEmpty || _generationEnCours) ? null : () => _genererRecap(courses),
            icon: _generationEnCours
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf_outlined),
            label: Text(_generationEnCours ? 'Génération en cours...' : 'Générer le récapitulatif'),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String valeur;

  const _StatTile({required this.label, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(valeur, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}