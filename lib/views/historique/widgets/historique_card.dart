// Emplacement cible : lib/views/historique/widgets/historique_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/course_model.dart';

/// Carte résumant une course clôturée dans la liste d'historique.
class HistoriqueCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onTap;

  const HistoriqueCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final dateLivraison = course.signatureDestinataire?.dateHeure;

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(
          child: Icon(Icons.inventory_2_outlined),
        ),
        title: Text(course.client),
        subtitle: Text(
          [
            if (course.referenceColis != null)
              'Colis ${course.referenceColis}',
            if (dateLivraison != null)
              'Livrée le ${dateFormat.format(dateLivraison)}',
          ].join(' · '),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}