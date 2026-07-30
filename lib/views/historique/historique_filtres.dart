// Emplacement cible : lib/views/historique/historique_filtres.dart
import 'package:flutter/material.dart';

import '../../models/course_model.dart';

/// Filtres appliqués à la liste de l'historique, en plus de la
/// recherche client (gérée séparément par une simple TextField
/// dans HistoriqueView).
@immutable
class HistoriqueFiltres {
  final String referenceColis;
  final DateTimeRange? plageDates;

  const HistoriqueFiltres({
    this.referenceColis = '',
    this.plageDates,
  });

  bool get estActif => referenceColis.trim().isNotEmpty || plageDates != null;

  HistoriqueFiltres copyWith({
    String? referenceColis,
    DateTimeRange? plageDates,
  }) {
    return HistoriqueFiltres(
      referenceColis: referenceColis ?? this.referenceColis,
      plageDates: plageDates ?? this.plageDates,
    );
  }

  /// Vérifie si une course correspond aux filtres réf. colis / date.
  /// La date de référence utilisée est la date de livraison
  /// (signature destinataire), affichée dans la carte de la liste.
  bool correspondA(CourseModel course) {
    if (referenceColis.trim().isNotEmpty) {
      final ref = course.referenceColis?.toLowerCase() ?? '';
      if (!ref.contains(referenceColis.trim().toLowerCase())) return false;
    }

    if (plageDates != null) {
      final dateLivraison = course.signatureDestinataire?.dateHeure;
      if (dateLivraison == null) return false;

      final jour = DateTime(dateLivraison.year, dateLivraison.month, dateLivraison.day);
      final debut = DateTime(
        plageDates!.start.year,
        plageDates!.start.month,
        plageDates!.start.day,
      );
      final fin = DateTime(
        plageDates!.end.year,
        plageDates!.end.month,
        plageDates!.end.day,
      );

      if (jour.isBefore(debut) || jour.isAfter(fin)) return false;
    }

    return true;
  }
}