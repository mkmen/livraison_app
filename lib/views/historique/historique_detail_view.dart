// Emplacement cible : lib/views/historique/historique_detail_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../store/course_store.dart';
import '../course_detail/widgets/carte_info.dart';

/// Consultation d'une course clôturée : adresses, référence colis,
/// et les deux signatures avec horodatage.
///
/// Contrairement à CourseDetailView (vue de suivi actif d'une
/// course en cours), cette vue est purement en lecture — pas
/// d'actions de changement de statut ici.
class HistoriqueDetailView extends StatelessWidget {
  final String courseId;

  const HistoriqueDetailView({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final course = CourseStore.instance.getById(courseId);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    if (course == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Historique')),
        body: const Center(child: Text('Course introuvable.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Course - ${course.client}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CarteInfo(course: course, dateFormat: dateFormat),
          const SizedBox(height: 24),
          // TODO: bouton "Envoyer la preuve de livraison" — branché
          // ici une fois le format d'export/envoi défini.
        ],
      ),
    );
  }
}