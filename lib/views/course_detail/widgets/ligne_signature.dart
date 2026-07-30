import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/course_model.dart';

class LigneSignature extends StatelessWidget {
  final String titre;
  final SignatureInfo info;
  final DateFormat dateFormat;

  const LigneSignature({
    super.key,
    required this.titre,
    required this.info,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 60,
            height: 40,
            color: Colors.white,
            child: Image.memory(info.imageBytes, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '$titre\nle ${dateFormat.format(info.dateHeure)}',
          ),
        ),
        const Icon(Icons.check_circle, color: Colors.green),
      ],
    );
  }
}