// Emplacement cible : lib/views/historique/historique_detail_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/course_model.dart';
import '../../services/preuve_livraison_service.dart';
import '../../store/course_store.dart';
import '../course_detail/widgets/carte_info.dart';

/// Consultation d'une course clôturée : adresses, référence colis,
/// et les deux signatures avec horodatage. Permet aussi l'envoi de
/// la preuve de livraison (PDF) via le partage natif.
///
/// Contrairement à CourseDetailView (vue de suivi actif d'une
/// course en cours), cette vue est purement en lecture pour les
/// données de la course — pas d'actions de changement de statut ici.
class HistoriqueDetailView extends StatefulWidget {
  final String courseId;

  const HistoriqueDetailView({super.key, required this.courseId});

  @override
  State<HistoriqueDetailView> createState() => _HistoriqueDetailViewState();
}

class _HistoriqueDetailViewState extends State<HistoriqueDetailView> {
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  bool _envoiEnCours = false;

  CourseModel? get _course => CourseStore.instance.getById(widget.courseId);

  Future<void> _envoyerPreuve(CourseModel course) async {
    setState(() => _envoiEnCours = true);
    try {
      await PreuveLivraisonService.partager(course);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de l\'envoi de la preuve : $e')),
      );
    } finally {
      if (mounted) setState(() => _envoiEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = _course;

    if (course == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Historique')),
        body: const Center(child: Text('Course introuvable.')),
      );
    }

    final preuveDisponible =
        course.signatureExpediteur != null && course.signatureDestinataire != null;

    return Scaffold(
      appBar: AppBar(title: Text('Course - ${course.client}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CarteInfo(course: course, dateFormat: _dateFormat),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: (!preuveDisponible || _envoiEnCours)
                ? null
                : () => _envoyerPreuve(course),
            icon: _envoiEnCours
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_outlined),
            label: Text(
              _envoiEnCours
                  ? 'Génération en cours...'
                  : 'Envoyer la preuve de livraison',
            ),
          ),
          if (!preuveDisponible)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Les deux signatures sont requises pour générer la preuve.',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}