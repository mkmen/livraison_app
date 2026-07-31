import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routes/app_routes.dart';

/// Écran menu de l'onglet Facturation : accès aux 3 fonctions
/// (montants des courses, facture client, récap mensuel). Chacune
/// est un écran dédié accessible via une route imbriquée, sur le
/// même principe que les routes de détail de l'historique.
class FacturationView extends StatelessWidget {
  const FacturationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Facturation')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MenuFacturationTile(
            icone: Icons.euro,
            titre: 'Montants des courses',
            sousTitre: 'Saisir ou modifier le montant de chaque course',
            onTap: () => context.push(AppRoutes.facturationMontants),
          ),
          const SizedBox(height: 12),
          _MenuFacturationTile(
            icone: Icons.receipt_long,
            titre: 'Facture client',
            sousTitre: 'Éditer une facture pour un client sur une période',
            onTap: () => context.push(AppRoutes.facturationFactureClient),
          ),
          const SizedBox(height: 12),
          _MenuFacturationTile(
            icone: Icons.bar_chart,
            titre: 'Récapitulatif mensuel',
            sousTitre: "Suivi de l'activité et du chiffre d'affaires",
            onTap: () => context.push(AppRoutes.facturationRecap),
          ),
        ],
      ),
    );
  }
}

class _MenuFacturationTile extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String sousTitre;
  final VoidCallback onTap;

  const _MenuFacturationTile({
    required this.icone,
    required this.titre,
    required this.sousTitre,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(child: Icon(icone)),
        title: Text(titre),
        subtitle: Text(sousTitre),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}