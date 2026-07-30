import 'package:flutter/material.dart';

class LigneInfo extends StatelessWidget {
  final IconData icone;
  final String label;
  final String valeur;

  const LigneInfo({
    super.key,
    required this.icone,
    required this.label,
    required this.valeur,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(text: '$label : ', style: const TextStyle(fontWeight: FontWeight.w600)),
                  TextSpan(text: valeur),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}