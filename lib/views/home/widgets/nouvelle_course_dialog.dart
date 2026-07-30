import 'package:flutter/material.dart';

import '../../../models/course_model.dart';
import '../../../store/client_store.dart';

/// Formulaire de déclaration d'une nouvelle course (Client, adresse
/// expéditeur, adresse destinataire). Le champ Client propose une
/// auto-complétion basée sur les clients déjà saisis précédemment
/// (ClientStore). Les adresses ne sont pas encore reliées à un
/// service d'autocomplétion.
class NouvelleCourseDialog extends StatefulWidget {
  const NouvelleCourseDialog({super.key});

  @override
  State<NouvelleCourseDialog> createState() => _NouvelleCourseDialogState();
}

class _NouvelleCourseDialogState extends State<NouvelleCourseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _adresseExpediteurController = TextEditingController();
  final _adresseDestinataireController = TextEditingController();

  // Référence vers le TextEditingController interne du champ Client,
  // fourni par Autocomplete via fieldViewBuilder. On la garde pour
  // pouvoir lire la valeur saisie au moment de l'enregistrement.
  TextEditingController? _clientTextController;

  @override
  void dispose() {
    _adresseExpediteurController.dispose();
    _adresseDestinataireController.dispose();
    super.dispose();
  }

  void _enregistrer() {
    if (!_formKey.currentState!.validate()) return;

    final client = (_clientTextController?.text ?? '').trim();

    // Mémorise le client pour l'auto-complétion des prochaines courses.
    ClientStore.instance.ajouterClient(client);

    final course = CourseModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      client: client,
      adresseExpediteur: _adresseExpediteurController.text.trim(),
      adresseDestinataire: _adresseDestinataireController.text.trim(),
    );
    Navigator.of(context).pop(course);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvelle course'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                final saisie = textEditingValue.text.trim().toLowerCase();
                if (saisie.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return ClientStore.instance.clients.where(
                  (client) => client.toLowerCase().contains(saisie),
                );
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                _clientTextController = controller;
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Client'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          return ListTile(
                            dense: true,
                            title: Text(option),
                            onTap: () => onSelected(option),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _adresseExpediteurController,
              decoration: const InputDecoration(labelText: "Adresse d'expéditeur"),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _adresseDestinataireController,
              decoration: const InputDecoration(labelText: 'Adresse de destinataire'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _enregistrer,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}