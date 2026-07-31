import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Ouvre un bottom sheet de saisie du montant d'une course.
/// Retourne le montant saisi (double) ou null si annulé.
Future<double?> afficherMontantDialog(
  BuildContext context, {
  required String client,
  double? montantActuel,
}) {
  final controleur = TextEditingController(
    text: montantActuel != null ? montantActuel.toStringAsFixed(2) : '',
  );
  final formKey = GlobalKey<FormState>();

  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(client, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              const Text('Montant de la course', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              TextFormField(
                controller: controleur,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Montant',
                  suffixText: '€',
                  border: OutlineInputBorder(),
                ),
                validator: (valeur) {
                  if (valeur == null || valeur.trim().isEmpty) {
                    return 'Le montant est requis';
                  }
                  final parsed = double.tryParse(valeur.replaceAll(',', '.'));
                  if (parsed == null || parsed < 0) {
                    return 'Montant invalide';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _valider(context, formKey, controleur),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _valider(context, formKey, controleur),
                      child: const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _valider(
  BuildContext context,
  GlobalKey<FormState> formKey,
  TextEditingController controleur,
) {
  if (!formKey.currentState!.validate()) return;
  final montant = double.parse(controleur.text.replaceAll(',', '.'));
  Navigator.of(context).pop(montant);
}