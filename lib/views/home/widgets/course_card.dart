import 'package:flutter/material.dart';

import '../../../models/course_model.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onTap;

  const CourseCard({super.key, required this.course, required this.onTap});

  Color _couleurStatus() {
    switch (course.status) {
      case CourseStatus.declaree:
        return Colors.orange;
      case CourseStatus.priseEnCharge:
        return Colors.blue;
      case CourseStatus.livree:
        return Colors.green;
      case CourseStatus.cloturee:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final couleur = _couleurStatus();

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: couleur.withOpacity(0.15),
          child: Icon(Icons.inventory_2_outlined, color: couleur),
        ),
        title: Text(course.client, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${course.adresseExpediteur} → ${course.adresseDestinataire}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Chip(
          label: Text(course.status.label),
          backgroundColor: couleur.withOpacity(0.15),
          labelStyle: TextStyle(color: couleur),
          side: BorderSide.none,
        ),
      ),
    );
  }
}