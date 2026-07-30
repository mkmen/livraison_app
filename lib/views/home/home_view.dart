import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/course_model.dart';
import '../../routes/app_routes.dart';
import '../../store/course_store.dart';
import 'widgets/course_card.dart';
import 'widgets/etat_vide.dart';
import 'widgets/nouvelle_course_dialog.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  Future<void> _declarerCourse(BuildContext context) async {
    final course = await showDialog<CourseModel>(
      context: context,
      builder: (_) => const NouvelleCourseDialog(),
    );
    if (course != null) {
      CourseStore.instance.ajouterCourse(course);
    }
  }

  void _ouvrirCourse(BuildContext context, CourseModel course) {
    context.push(AppRoutes.detailsPath(course.id));
  }

  Future<bool> _confirmerSuppression(BuildContext context, CourseModel course) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la course ?'),
        content: Text(
          'La course de "${course.client}" et ses éventuelles signatures seront définitivement supprimées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    return confirme ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      body: ListenableBuilder(
        listenable: CourseStore.instance,
        builder: (context, _) {
          final courses = CourseStore.instance.courses;

          if (courses.isEmpty) {
            return const EtatVide();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final course = courses[index];
              return Dismissible(
                key: ValueKey(course.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _confirmerSuppression(context, course),
                onDismissed: (_) => CourseStore.instance.supprimerCourse(course.id),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                child: CourseCard(
                  course: course,
                  onTap: () => _ouvrirCourse(context, course),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _declarerCourse(context),
        icon: const Icon(Icons.add),
        label: const Text('Déclarer une course'),
      ),
    );
  }
}