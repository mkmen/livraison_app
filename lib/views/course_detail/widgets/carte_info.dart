import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/course_model.dart';
import 'ligne_info.dart';
import 'ligne_signature.dart';

class CarteInfo extends StatelessWidget {
  final CourseModel course;
  final DateFormat dateFormat;

  const CarteInfo({super.key, required this.course, required this.dateFormat});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  course.client,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Chip(label: Text(course.status.label)),
              ],
            ),
            const SizedBox(height: 12),
            LigneInfo(icone: Icons.call_made, label: 'Expéditeur', valeur: course.adresseExpediteur),
            LigneInfo(icone: Icons.pin_drop_outlined, label: 'Destinataire', valeur: course.adresseDestinataire),
            if (course.referenceColis != null)
              LigneInfo(icone: Icons.qr_code, label: 'Référence colis', valeur: course.referenceColis!),
            const Divider(height: 24),
            if (course.signatureExpediteur != null)
              LigneSignature(
                titre: 'Prise en charge signée',
                info: course.signatureExpediteur!,
                dateFormat: dateFormat,
              )
            else
              const Text('Prise en charge : en attente'),
            const SizedBox(height: 8),
            if (course.signatureDestinataire != null)
              LigneSignature(
                titre: 'Réception signée',
                info: course.signatureDestinataire!,
                dateFormat: dateFormat,
              )
            else
              const Text('Réception : en attente'),
          ],
        ),
      ),
    );
  }
}