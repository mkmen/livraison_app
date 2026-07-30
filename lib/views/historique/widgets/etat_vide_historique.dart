// Emplacement cible : lib/views/historique/widgets/etat_vide_historique.dart
import 'package:flutter/material.dart';

/// État vide affiché quand aucune course clôturée n'existe encore,
/// ou quand la recherche/les filtres ne retournent aucun résultat.
class EtatVideHistorique extends StatelessWidget {
  final bool filtresActifs;

  const EtatVideHistorique({super.key, this.filtresActifs = false});

  @override
  Widget build(BuildContext context) {
    final titre = filtresActifs
        ? 'Aucun résultat pour cette recherche'
        : 'Aucune course clôturée pour le moment';
    final sousTitre = filtresActifs
        ? 'Essayez avec un autre client, une autre référence ou une autre période.'
        : 'Les courses apparaissent ici une fois livrées et clôturées.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filtresActifs ? Icons.search_off : Icons.history,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              titre,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              sousTitre,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}