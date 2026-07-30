import 'dart:typed_data';

/// Étapes du cycle de vie d'une course.
enum CourseStatus {
  declaree,        // course créée, colis pas encore pris en charge
  priseEnCharge,   // colis récupéré, signature expéditeur faite
  livree,          // colis livré, signature destinataire faite
  cloturee,        // course terminée et archivée
}

extension CourseStatusLabel on CourseStatus {
  String get label {
    switch (this) {
      case CourseStatus.declaree:
        return 'Déclarée';
      case CourseStatus.priseEnCharge:
        return 'Prise en charge';
      case CourseStatus.livree:
        return 'Livrée';
      case CourseStatus.cloturee:
        return 'Clôturée';
    }
  }
}

/// Preuve de signature : image (png) + horodatage.
class SignatureInfo {
  final Uint8List imageBytes;
  final DateTime dateHeure;

  SignatureInfo({
    required this.imageBytes,
    required this.dateHeure,
  });
}

class CourseModel {
  final String id;
  final String client;
  final String adresseExpediteur;
  final String adresseDestinataire;
  final DateTime dateCreation;

  String? referenceColis;
  SignatureInfo? signatureExpediteur;
  SignatureInfo? signatureDestinataire;
  CourseStatus status;

  CourseModel({
    required this.id,
    required this.client,
    required this.adresseExpediteur,
    required this.adresseDestinataire,
    DateTime? dateCreation,
    this.status = CourseStatus.declaree,
  }) : dateCreation = dateCreation ?? DateTime.now();

  bool get estPriseEnCharge => signatureExpediteur != null;
  bool get estLivree => signatureDestinataire != null;

  /// Une course peut être clôturée une fois les deux signatures obtenues.
  bool get peutEtreCloturee =>
      estPriseEnCharge && estLivree && status != CourseStatus.cloturee;
}