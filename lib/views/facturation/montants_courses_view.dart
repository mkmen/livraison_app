// Emplacement cible : lib/views/facturation/montants_courses_view.dart
import 'package:flutter/material.dart';

import '../../models/course_model.dart';
import '../../store/course_store.dart';
import 'widgets/course_montant_card.dart';
import 'widgets/montant_dialog.dart';

/// Trie les courses sans montant renseigné en premier (ce sont elles
/// qu'il faut traiter en priorité), puis les plus récentes en premier
/// au sein de chaque groupe (avec/sans montant).
int _comparerPourTri(CourseModel a, CourseModel b) {
  final aSansMontant = a.montant == null;
  final bSansMontant = b.montant == null;
  if (aSansMontant != bSansMontant) {
    return aSansMontant ? -1 : 1;
  }
  return b.dateCreation.compareTo(a.dateCreation);
}

/// Liste toutes les courses et permet de saisir/modifier leur montant
/// via un tap ouvrant un bottom sheet de saisie (afficherMontantDialog).
class MontantsCoursesView extends StatelessWidget {
  const MontantsCoursesView({super.key});

  Future<void> _saisirMontant(BuildContext context, CourseModel course) async {
    final montant = await afficherMontantDialog(
      context,
      client: course.client,
      montantActuel: course.montant,
    );
    if (montant == null) return;

    course.montant = montant;
    CourseStore.instance.notifierChangement();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Montants des courses')),
      body: ListenableBuilder(
        listenable: CourseStore.instance,
        builder: (context, _) {
          final courses = List<CourseModel>.of(CourseStore.instance.courses)
            ..sort(_comparerPourTri);

          if (courses.isEmpty) {
            return const Center(child: Text('Aucune course pour le moment.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final course = courses[index];
              return CourseMontantCard(
                course: course,
                onTap: () => _saisirMontant(context, course),
              );
            },
          );
        },
      ),
    );
  }
}