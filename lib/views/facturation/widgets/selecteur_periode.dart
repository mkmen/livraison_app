import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum ModePeriode { mois, plage }

const _nomsMois = [
  'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
  'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
];

/// Sélecteur de période réutilisable : mois calendaire (navigation par
/// flèches) ou plage de dates libre (date range picker natif, comme
/// dans HistoriqueView). Notifie le parent via [onChanged] avec les
/// bornes [debut, fin] (fin = dernier jour de la période inclus).
///
/// Notifie le mois courant dès l'affichage, pour éviter d'avoir une
/// période nulle tant que l'utilisateur n'a rien choisi.
class SelecteurPeriode extends StatefulWidget {
  final void Function(DateTime debut, DateTime fin) onChanged;

  const SelecteurPeriode({super.key, required this.onChanged});

  @override
  State<SelecteurPeriode> createState() => _SelecteurPeriodeState();
}

class _SelecteurPeriodeState extends State<SelecteurPeriode> {
  ModePeriode _mode = ModePeriode.mois;
  DateTime _moisSelectionne = DateTime(DateTime.now().year, DateTime.now().month);
  DateTimeRange? _plageSelectionnee;

  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifierMois());
  }

  void _notifierMois() {
    final debut = DateTime(_moisSelectionne.year, _moisSelectionne.month, 1);
    final finExclusive = DateTime(_moisSelectionne.year, _moisSelectionne.month + 1, 1);
    final fin = finExclusive.subtract(const Duration(days: 1));
    widget.onChanged(debut, fin);
  }

  void _changerMois(int delta) {
    setState(() {
      _moisSelectionne = DateTime(_moisSelectionne.year, _moisSelectionne.month + delta);
    });
    _notifierMois();
  }

  Future<void> _choisirPlage() async {
    final maintenant = DateTime.now();
    final plage = await showDateRangePicker(
      context: context,
      firstDate: DateTime(maintenant.year - 3),
      lastDate: DateTime(maintenant.year + 1),
      initialDateRange: _plageSelectionnee,
    );
    if (plage == null) return;
    setState(() => _plageSelectionnee = plage);
    widget.onChanged(plage.start, plage.end);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<ModePeriode>(
          segments: const [
            ButtonSegment(
              value: ModePeriode.mois,
              label: Text('Mois'),
              icon: Icon(Icons.calendar_view_month),
            ),
            ButtonSegment(
              value: ModePeriode.plage,
              label: Text('Période libre'),
              icon: Icon(Icons.date_range),
            ),
          ],
          selected: {_mode},
          onSelectionChanged: (selection) {
            setState(() => _mode = selection.first);
            if (_mode == ModePeriode.mois) {
              _notifierMois();
            } else if (_plageSelectionnee != null) {
              widget.onChanged(_plageSelectionnee!.start, _plageSelectionnee!.end);
            }
          },
        ),
        const SizedBox(height: 12),
        if (_mode == ModePeriode.mois)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: () => _changerMois(-1), icon: const Icon(Icons.chevron_left)),
              SizedBox(
                width: 160,
                child: Text(
                  '${_nomsMois[_moisSelectionne.month - 1]} ${_moisSelectionne.year}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(onPressed: () => _changerMois(1), icon: const Icon(Icons.chevron_right)),
            ],
          )
        else
          OutlinedButton.icon(
            onPressed: _choisirPlage,
            icon: const Icon(Icons.date_range),
            label: Text(
              _plageSelectionnee == null
                  ? 'Choisir une plage de dates'
                  : '${_dateFormat.format(_plageSelectionnee!.start)} - ${_dateFormat.format(_plageSelectionnee!.end)}',
            ),
          ),
      ],
    );
  }
}