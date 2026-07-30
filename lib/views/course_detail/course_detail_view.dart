import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/course_model.dart';
import '../../store/course_store.dart';
import '../signature_capture/signature_capture_view.dart';
import 'widgets/carte_info.dart';

class CourseDetailView extends StatefulWidget {
  final String courseId;

  const CourseDetailView({super.key, required this.courseId});

  @override
  State<CourseDetailView> createState() => _CourseDetailViewState();
}

class _CourseDetailViewState extends State<CourseDetailView> {
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  CourseModel get _course => CourseStore.instance.getById(widget.courseId)!;

  Future<void> _prendreEnCharge() async {
    final reference = await _demanderReferenceColis();
    if (reference == null || reference.trim().isEmpty) return;

    if (!mounted) return;
    final Uint8List? signature = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        builder: (_) => const SignatureCaptureView(
          titre: 'Prise en charge du colis',
          consigne:
              "L'expéditeur signe ci-dessous pour attester la remise du colis au livreur.",
        ),
      ),
    );
    if (signature == null) return;

    setState(() {
      final course = _course;
      course.referenceColis = reference.trim();
      course.signatureExpediteur = SignatureInfo(
        imageBytes: signature,
        dateHeure: DateTime.now(),
      );
      course.status = CourseStatus.priseEnCharge;
    });
    CourseStore.instance.notifierChangement();
  }

  Future<String?> _demanderReferenceColis() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Référence du colis'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Référence',
            hintText: 'Ex : COL-2026-00123',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmerLivraison() async {
    final Uint8List? signature = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        builder: (_) => const SignatureCaptureView(
          titre: 'Preuve de réception',
          consigne:
              'Le destinataire signe ci-dessous pour attester la bonne réception du colis.',
        ),
      ),
    );
    if (signature == null) return;

    setState(() {
      final course = _course;
      course.signatureDestinataire = SignatureInfo(
        imageBytes: signature,
        dateHeure: DateTime.now(),
      );
      course.status = CourseStatus.livree;
    });
    CourseStore.instance.notifierChangement();
  }

  void _cloturer() {
    setState(() {
      _course.status = CourseStatus.cloturee;
    });
    CourseStore.instance.notifierChangement();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final course = _course;

    return Scaffold(
      appBar: AppBar(
        title: Text('Course - ${course.client}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CarteInfo(course: course, dateFormat: _dateFormat),
          const SizedBox(height: 24),
          if (course.status == CourseStatus.declaree)
            FilledButton.icon(
              onPressed: _prendreEnCharge,
              icon: const Icon(Icons.inventory_2_outlined),
              label: const Text('Prise en charge du colis'),
            ),
          if (course.status == CourseStatus.priseEnCharge)
            FilledButton.icon(
              onPressed: _confirmerLivraison,
              icon: const Icon(Icons.how_to_reg),
              label: const Text('Signature de réception (destinataire)'),
            ),
          if (course.peutEtreCloturee) ...[
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: _cloturer,
              icon: const Icon(Icons.lock_outline),
              label: const Text('Clôturer la course'),
            ),
          ],
          if (course.status == CourseStatus.cloturee)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Cette course est clôturée.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }
}