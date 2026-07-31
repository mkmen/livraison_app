import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/course_model.dart';

/// Carte listant une course avec son montant (ou "Non renseigné").
/// Tap pour ouvrir la saisie/modification du montant.
class CourseMontantCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onTap;

  const CourseMontantCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final montantRenseigne = course.montant != null;

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: montantRenseigne ? Colors.green.shade100 : Colors.orange.shade100,
          child: Icon(
            montantRenseigne ? Icons.euro : Icons.euro_outlined,
            color: montantRenseigne ? Colors.green.shade800 : Colors.orange.shade800,
          ),
        ),
        title: Text(course.client),
        subtitle: Text(
          [
            dateFormat.format(course.dateCreation),
            if (course.referenceColis != null) 'Colis ${course.referenceColis}',
          ].join(' · '),
        ),
        trailing: Text(
          montantRenseigne ? '${course.montant!.toStringAsFixed(2)} €' : 'Non renseigné',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: montantRenseigne ? Colors.green.shade800 : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}