import 'package:flutter/material.dart';

import '../../../models/course_model.dart';

/// Formulaire de déclaration d'une nouvelle course (Client, adresse
/// expéditeur, adresse destinataire). Pas encore relié à un service
/// d'autocomplétion d'adresses.
class NouvelleCourseDialog extends StatefulWidget {
  const NouvelleCourseDialog({super.key});

  @override
  State<NouvelleCourseDialog> createState() => _NouvelleCourseDialogState();
}

class _NouvelleCourseDialogState extends State<NouvelleCourseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _clientController = TextEditingController();
  final _adresseExpediteurController = TextEditingController();
  final _adresseDestinataireController = TextEditingController();

  @override
  void dispose() {
    _clientController.dispose();
    _adresseExpediteurController.dispose();
    _adresseDestinataireController.dispose();
    super.dispose();
  }

  void _enregistrer() {
    if (!_formKey.currentState!.validate()) return;

    final course = CourseModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      client: _clientController.text.trim(),
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
            TextFormField(
              controller: _clientController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Client'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
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