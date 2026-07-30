// Emplacement cible : lib/services/preuve_livraison_service.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/course_model.dart';

/// Génère et partage la preuve de livraison (PDF) d'une course clôturée.
///
/// Contient les adresses, la référence colis, et les deux signatures
/// (expéditeur / destinataire) avec leur date/heure.
class PreuveLivraisonService {
  PreuveLivraisonService._();

  static final _dateFormat = DateFormat('dd/MM/yyyy à HH:mm');

  /// Construit le PDF en mémoire et retourne ses octets.
  static Future<Uint8List> genererPdf(CourseModel course) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Preuve de livraison',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Course n° ${course.id}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 24),

              _sectionInfos(course),
              pw.SizedBox(height: 24),

              pw.Divider(),
              pw.SizedBox(height: 12),

              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: _sectionSignature(
                      titre: 'Prise en charge (expéditeur)',
                      signature: course.signatureExpediteur,
                    ),
                  ),
                  pw.SizedBox(width: 24),
                  pw.Expanded(
                    child: _sectionSignature(
                      titre: 'Réception (destinataire)',
                      signature: course.signatureDestinataire,
                    ),
                  ),
                ],
              ),

              pw.Spacer(),
              pw.Divider(),
              pw.Text(
                'Document généré le ${_dateFormat.format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _sectionInfos(CourseModel course) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _ligneInfo('Client', course.client),
          _ligneInfo('Adresse d\'enlèvement', course.adresseExpediteur),
          _ligneInfo('Adresse de livraison', course.adresseDestinataire),
          if (course.referenceColis != null)
            _ligneInfo('Référence colis', course.referenceColis!),
          _ligneInfo('Déclarée le', _dateFormat.format(course.dateCreation)),
        ],
      ),
    );
  }

  static pw.Widget _ligneInfo(String label, String valeur) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 130,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(valeur, style: const pw.TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _sectionSignature({
    required String titre,
    required SignatureInfo? signature,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          titre,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        if (signature == null)
          pw.Text(
            'Non renseignée',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
          )
        else ...[
          pw.Container(
            height: 100,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
            ),
            child: pw.Image(
              pw.MemoryImage(signature.imageBytes),
              fit: pw.BoxFit.contain,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Signé le ${_dateFormat.format(signature.dateHeure)}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ],
      ],
    );
  }

  /// Génère le PDF, l'écrit dans un fichier temporaire, puis ouvre
  /// la feuille de partage native (mail, SMS, WhatsApp, etc.).
  static Future<void> partager(CourseModel course) async {
    final bytes = await genererPdf(course);

    final dir = await getTemporaryDirectory();
    final fileName = 'preuve_livraison_${course.id}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf', name: fileName)],
      subject: 'Preuve de livraison - ${course.client}',
      text: 'Voici la preuve de livraison pour la course de ${course.client}.',
    );
  }
}