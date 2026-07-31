import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/course_model.dart';

/// Génère et partage les documents de facturation :
/// - facture PDF pour un client sur une période donnée
/// - récapitulatif d'activité PDF sur une période donnée
///
/// Auto-entrepreneur / franchise en base : pas de calcul de TVA, la
/// mention légale correspondante est ajoutée sur la facture.
///
/// Numérotation de facture : compteur séquentiel simple, en mémoire
/// (format FAC-AAAA-NNN). C'est volontairement basique pour l'instant,
/// comme le reste du stockage du projet — à professionnaliser (numéro
/// persistant, jamais réutilisé même après réinstallation de l'app)
/// une fois Firebase branché, car la loi impose une numérotation
/// séquentielle sans trou pour les factures.
class FacturationService {
  FacturationService._();

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _dateHeureFormat = DateFormat('dd/MM/yyyy à HH:mm');

  static int _compteurFactures = 0;

  static String _formaterMontant(double valeur) => '${valeur.toStringAsFixed(2)} €';

  /// Courses d'un client sur une période, triées par date croissante,
  /// ne retenant que celles dont le montant a été renseigné.
  /// La comparaison du nom de client est insensible à la casse et aux
  /// espaces superflus, comme pour ClientStore.
  static List<CourseModel> courseFacturables({
    required List<CourseModel> toutesLesCourses,
    required String client,
    required DateTime debut,
    required DateTime fin,
  }) {
    final finInclusive = DateTime(fin.year, fin.month, fin.day, 23, 59, 59);
    final clientNettoye = client.trim().toLowerCase();

    final courses = toutesLesCourses.where((c) {
      final memeClient = c.client.trim().toLowerCase() == clientNettoye;
      final dansLaPeriode =
          !c.dateCreation.isBefore(debut) && !c.dateCreation.isAfter(finInclusive);
      return memeClient && dansLaPeriode && c.montant != null;
    }).toList();

    courses.sort((a, b) => a.dateCreation.compareTo(b.dateCreation));
    return courses;
  }

  /// Toutes les courses sur une période (tous clients confondus),
  /// triées par date croissante — utilisé pour le récap d'activité.
  static List<CourseModel> coursesSurPeriode({
    required List<CourseModel> toutesLesCourses,
    required DateTime debut,
    required DateTime fin,
  }) {
    final finInclusive = DateTime(fin.year, fin.month, fin.day, 23, 59, 59);

    final courses = toutesLesCourses.where((c) {
      return !c.dateCreation.isBefore(debut) && !c.dateCreation.isAfter(finInclusive);
    }).toList();

    courses.sort((a, b) => a.dateCreation.compareTo(b.dateCreation));
    return courses;
  }

  static String _prochainNumeroFacture() {
    _compteurFactures++;
    return 'FAC-${DateTime.now().year}-${_compteurFactures.toString().padLeft(3, '0')}';
  }

  /// Construit le PDF de facture en mémoire et retourne ses octets.
  /// [courses] doit déjà être filtrée (voir courseFacturables).
  static Future<Uint8List> genererFacturePdf({
    required String client,
    required DateTime debut,
    required DateTime fin,
    required List<CourseModel> courses,
  }) async {
    final numeroFacture = _prochainNumeroFacture();
    final total = courses.fold<double>(0, (somme, c) => somme + (c.montant ?? 0));

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => context.pageNumber == 1 ? _enteteFacture(numeroFacture, client, debut, fin) : pw.SizedBox(),
        footer: (context) => _piedDePage(context),
        build: (context) => [
          _tableauCourses(courses),
          pw.SizedBox(height: 16),
          _blocTotal(courses.length, total),
          pw.SizedBox(height: 24),
          pw.Text(
            'TVA non applicable, art. 293 B du CGI.',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _enteteFacture(String numero, String client, DateTime debut, DateTime fin) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Facture', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.Text(numero, style: const pw.TextStyle(fontSize: 12)),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Text('Client : $client', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.Text(
          'Période : ${_dateFormat.format(debut)} - ${_dateFormat.format(fin)}',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 16),
      ],
    );
  }

  static pw.Widget _piedDePage(pw.Context context) {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.Text(
          'Document généré le ${_dateHeureFormat.format(DateTime.now())} - Page ${context.pageNumber}/${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
        ),
      ],
    );
  }

  static pw.Widget _tableauCourses(List<CourseModel> courses) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(2),
        1: pw.FlexColumnWidth(3),
        2: pw.FlexColumnWidth(2),
        3: pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _celluleEntete('Date'),
            _celluleEntete('Trajet'),
            _celluleEntete('Référence'),
            _celluleEntete('Montant', alignement: pw.Alignment.centerRight),
          ],
        ),
        ...courses.map(
          (c) => pw.TableRow(
            children: [
              _cellule(_dateFormat.format(c.dateCreation)),
              _cellule('${c.adresseExpediteur} -> ${c.adresseDestinataire}'),
              _cellule(c.referenceColis ?? '-'),
              _cellule(_formaterMontant(c.montant!), alignement: pw.Alignment.centerRight),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _blocTotal(int nombreCourses, double total) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text('Nombre de courses : $nombreCourses', style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 4),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey700)),
            child: pw.Text(
              'Total : ${_formaterMontant(total)}',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _celluleEntete(String texte, {pw.Alignment alignement = pw.Alignment.centerLeft}) {
    return pw.Container(
      alignment: alignement,
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(texte, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
    );
  }

  static pw.Widget _cellule(String texte, {pw.Alignment alignement = pw.Alignment.centerLeft}) {
    return pw.Container(
      alignment: alignement,
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(texte, style: const pw.TextStyle(fontSize: 9)),
    );
  }

  /// Génère la facture, l'écrit dans un fichier temporaire, puis ouvre
  /// la feuille de partage native (mail, SMS, WhatsApp, etc.).
  static Future<void> genererEtPartagerFacture({
    required String client,
    required DateTime debut,
    required DateTime fin,
    required List<CourseModel> courses,
  }) async {
    final bytes = await genererFacturePdf(client: client, debut: debut, fin: fin, courses: courses);

    final dir = await getTemporaryDirectory();
    final fileName = 'facture_${client.replaceAll(' ', '_')}_${DateFormat('yyyyMM').format(debut)}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf', name: fileName)],
      subject: 'Facture - $client',
      text: 'Facture pour $client, période du ${_dateFormat.format(debut)} au ${_dateFormat.format(fin)}.',
    );
  }

  /// Construit le PDF de récapitulatif d'activité sur une période et
  /// retourne ses octets. [courses] n'a pas besoin d'être pré-filtrée
  /// par montant : les courses sans montant sont listées mais exclues
  /// du chiffre d'affaires, avec une mention dédiée.
  static Future<Uint8List> genererRecapPdf({
    required DateTime debut,
    required DateTime fin,
    required List<CourseModel> courses,
  }) async {
    final coursesFacturees = courses.where((c) => c.montant != null).toList();
    final coursesSansMontant = courses.where((c) => c.montant == null).toList();
    final total = coursesFacturees.fold<double>(0, (somme, c) => somme + (c.montant ?? 0));

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => context.pageNumber == 1 ? _enteteRecap(debut, fin) : pw.SizedBox(),
        footer: (context) => _piedDePage(context),
        build: (context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _statCard('Courses réalisées', '${courses.length}'),
              _statCard('Courses facturées', '${coursesFacturees.length}'),
              _statCard('Chiffre d\'affaires', _formaterMontant(total)),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('Détail des courses', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(3),
              3: pw.FlexColumnWidth(1.5),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _celluleEntete('Date'),
                  _celluleEntete('Client'),
                  _celluleEntete('Trajet'),
                  _celluleEntete('Montant', alignement: pw.Alignment.centerRight),
                ],
              ),
              ...courses.map(
                (c) => pw.TableRow(
                  children: [
                    _cellule(_dateFormat.format(c.dateCreation)),
                    _cellule(c.client),
                    _cellule('${c.adresseExpediteur} -> ${c.adresseDestinataire}'),
                    _cellule(
                      c.montant != null ? _formaterMontant(c.montant!) : 'Non renseigné',
                      alignement: pw.Alignment.centerRight,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (coursesSansMontant.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Text(
              '${coursesSansMontant.length} course(s) sans montant renseigné, non comptabilisée(s) dans le chiffre d\'affaires.',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700, fontStyle: pw.FontStyle.italic),
            ),
          ],
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _enteteRecap(DateTime debut, DateTime fin) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Récapitulatif d\'activité', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(
          'Période : ${_dateFormat.format(debut)} - ${_dateFormat.format(fin)}',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 16),
      ],
    );
  }

  static pw.Widget _statCard(String label, String valeur) {
    return pw.Expanded(
      child: pw.Container(
        margin: const pw.EdgeInsets.symmetric(horizontal: 4),
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey400),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
            pw.SizedBox(height: 4),
            pw.Text(valeur, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  /// Génère le récap, l'écrit dans un fichier temporaire, puis ouvre
  /// la feuille de partage native.
  static Future<void> genererEtPartagerRecap({
    required DateTime debut,
    required DateTime fin,
    required List<CourseModel> courses,
  }) async {
    final bytes = await genererRecapPdf(debut: debut, fin: fin, courses: courses);

    final dir = await getTemporaryDirectory();
    final fileName = 'recap_activite_${DateFormat('yyyyMM').format(debut)}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf', name: fileName)],
      subject: 'Récapitulatif d\'activité',
      text: 'Récapitulatif d\'activité du ${_dateFormat.format(debut)} au ${_dateFormat.format(fin)}.',
    );
  }
}