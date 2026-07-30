// Emplacement cible : lib/views/historique/widgets/historique_filtres_sheet.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../historique_filtres.dart';

/// Bottom sheet ouvert via l'icône filtre de HistoriqueView.
/// Retourne le HistoriqueFiltres choisi via Navigator.pop, ou null
/// si l'utilisateur ferme le sheet sans valider.
class HistoriqueFiltresSheet extends StatefulWidget {
  final HistoriqueFiltres filtresInitiaux;

  const HistoriqueFiltresSheet({super.key, required this.filtresInitiaux});

  @override
  State<HistoriqueFiltresSheet> createState() => _HistoriqueFiltresSheetState();
}

class _HistoriqueFiltresSheetState extends State<HistoriqueFiltresSheet> {
  late final TextEditingController _refController;
  DateTimeRange? _plageDates;
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _refController = TextEditingController(text: widget.filtresInitiaux.referenceColis);
    _plageDates = widget.filtresInitiaux.plageDates;
  }

  @override
  void dispose() {
    _refController.dispose();
    super.dispose();
  }

  Future<void> _choisirPlage() async {
    final plage = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _plageDates,
    );
    if (plage != null) {
      setState(() => _plageDates = plage);
    }
  }

  void _reinitialiser() {
    setState(() {
      _refController.clear();
      _plageDates = null;
    });
  }

  void _appliquer() {
    Navigator.of(context).pop(
      HistoriqueFiltres(
        referenceColis: _refController.text,
        plageDates: _plageDates,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Filtres', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          TextField(
            controller: _refController,
            decoration: const InputDecoration(
              labelText: 'Référence colis',
              hintText: 'Ex : COL-2026-00123',
              prefixIcon: Icon(Icons.inventory_2_outlined),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _choisirPlage,
            icon: const Icon(Icons.date_range_outlined),
            label: Text(
              _plageDates == null
                  ? 'Sélectionner une plage de dates'
                  : '${_dateFormat.format(_plageDates!.start)} → ${_dateFormat.format(_plageDates!.end)}',
            ),
          ),
          if (_plageDates != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => setState(() => _plageDates = null),
                child: const Text('Effacer la plage de dates'),
              ),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _reinitialiser,
                  child: const Text('Réinitialiser'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _appliquer,
                  child: const Text('Appliquer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}