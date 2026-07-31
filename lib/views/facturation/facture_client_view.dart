import 'package:flutter/material.dart';

import '../../models/course_model.dart';
import '../../services/facturation_service.dart';
import '../../store/client_store.dart';
import '../../store/course_store.dart';
import 'widgets/selecteur_periode.dart';

/// Sélection d'un client (autocomplete via ClientStore) + d'une
/// période (mois ou plage libre via SelecteurPeriode), avec aperçu
/// des courses facturables, pour générer et partager la facture PDF
/// correspondante (voir FacturationService).
class FactureClientView extends StatefulWidget {
  const FactureClientView({super.key});

  @override
  State<FactureClientView> createState() => _FactureClientViewState();
}

class _FactureClientViewState extends State<FactureClientView> {
  String? _client;
  DateTime? _debut;
  DateTime? _fin;
  bool _generationEnCours = false;

  List<CourseModel> get _coursesFacturables {
    final client = _client;
    final debut = _debut;
    final fin = _fin;
    if (client == null || client.trim().isEmpty || debut == null || fin == null) {
      return const [];
    }
    return FacturationService.courseFacturables(
      toutesLesCourses: CourseStore.instance.courses,
      client: client,
      debut: debut,
      fin: fin,
    );
  }

  Future<void> _genererFacture() async {
    final client = _client;
    final debut = _debut;
    final fin = _fin;
    final courses = _coursesFacturables;
    if (client == null || debut == null || fin == null || courses.isEmpty) return;

    setState(() => _generationEnCours = true);
    try {
      await FacturationService.genererEtPartagerFacture(
        client: client,
        debut: debut,
        fin: fin,
        courses: courses,
      );
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
    final courses = _coursesFacturables;
    final total = courses.fold<double>(0, (somme, c) => somme + (c.montant ?? 0));
    final periodeChoisie = _debut != null && _fin != null;
    final clientChoisi = _client != null && _client!.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Facture client')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListenableBuilder(
            listenable: ClientStore.instance,
            builder: (context, _) {
              return Autocomplete<String>(
                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text.isEmpty) return ClientStore.instance.clients;
                  return ClientStore.instance.clients.where(
                    (c) => c.toLowerCase().contains(textEditingValue.text.toLowerCase()),
                  );
                },
                onSelected: (selection) => setState(() => _client = selection),
                fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Client',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (valeur) => setState(() => _client = valeur),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),
          SelecteurPeriode(
            onChanged: (debut, fin) => setState(() {
              _debut = debut;
              _fin = fin;
            }),
          ),
          const SizedBox(height: 20),
          if (courses.isNotEmpty)
            Text(
              '${courses.length} course(s) facturable(s) - Total : ${total.toStringAsFixed(2)} €',
              style: Theme.of(context).textTheme.titleMedium,
            )
          else if (clientChoisi && periodeChoisie)
            const Text(
              'Aucune course facturable pour ce client sur cette période.',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: (courses.isEmpty || _generationEnCours) ? null : _genererFacture,
            icon: _generationEnCours
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf_outlined),
            label: Text(_generationEnCours ? 'Génération en cours...' : 'Générer et partager la facture'),
          ),
        ],
      ),
    );
  }
}