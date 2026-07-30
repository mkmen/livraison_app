// Emplacement cible : lib/views/historique/historique_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/course_model.dart';
import '../../routes/app_routes.dart';
import '../../store/course_store.dart';
import 'widgets/etat_vide_historique.dart';
import 'widgets/historique_card.dart';

/// Liste les courses clôturées (historique / preuves de livraison).
class HistoriqueView extends StatelessWidget {
  const HistoriqueView({super.key});

  void _ouvrirCourse(BuildContext context, CourseModel course) {
    context.push(AppRoutes.historiqueDetailsPath(course.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: ListenableBuilder(
        listenable: CourseStore.instance,
        builder: (context, _) {
          // CourseStore.courses est déjà trié du plus récent au plus
          // ancien, le filtre conserve donc cet ordre.
          final coursesCloturees = CourseStore.instance.courses
              .where((c) => c.status == CourseStatus.cloturee)
              .toList();

          if (coursesCloturees.isEmpty) {
            return const EtatVideHistorique();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: coursesCloturees.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final course = coursesCloturees[index];
              return HistoriqueCard(
                course: course,
                onTap: () => _ouvrirCourse(context, course),
              );
            },
          );
        },
      ),
    );
  }
}