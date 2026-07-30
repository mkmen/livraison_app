import 'package:flutter/foundation.dart';

import '../models/course_model.dart';

/// Stocke les courses en mémoire pour l'instant.
/// Sera remplacé plus tard par un vrai service (API / base locale),
/// mais l'interface publique (ajouterCourse / getById / courses)
/// ne devrait pas changer, ce qui facilitera le branchement futur
/// de l'historique / preuve de livraison.
class CourseStore extends ChangeNotifier {
  CourseStore._();
  static final CourseStore instance = CourseStore._();

  final List<CourseModel> _courses = [];

  /// Les plus récentes en premier.
  List<CourseModel> get courses => List.unmodifiable(_courses.reversed);

  CourseModel? getById(String id) {
    for (final c in _courses) {
      if (c.id == id) return c;
    }
    return null;
  }

  void ajouterCourse(CourseModel course) {
    _courses.add(course);
    notifyListeners();
  }

  /// À appeler après avoir modifié un CourseModel récupéré via getById,
  /// pour prévenir les écrans qui écoutent le store.
  void notifierChangement() {
    notifyListeners();
  }
}