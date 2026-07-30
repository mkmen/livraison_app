import 'package:flutter/foundation.dart';

/// Mémorise les noms de clients déjà saisis lors de la déclaration
/// de courses, pour proposer une auto-complétion sur les prochaines.
///
/// Comme CourseStore, ceci est volontairement simple (en mémoire) et
/// sera à remplacer plus tard par un vrai service (API / base locale)
/// sans changer l'interface publique (ajouterClient / clients).
class ClientStore extends ChangeNotifier {
  ClientStore._();
  static final ClientStore instance = ClientStore._();

  final Set<String> _clients = {};

  /// Liste triée alphabétiquement (insensible à la casse).
  List<String> get clients {
    final liste = _clients.toList();
    liste.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return liste;
  }

  /// Ajoute un client s'il n'existe pas déjà (comparaison insensible
  /// à la casse pour éviter les doublons du type "Dupont" / "dupont").
  void ajouterClient(String nom) {
    final nomNettoye = nom.trim();
    if (nomNettoye.isEmpty) return;

    final dejaPresent = _clients.any(
      (c) => c.toLowerCase() == nomNettoye.toLowerCase(),
    );
    if (dejaPresent) return;

    _clients.add(nomNettoye);
    notifyListeners();
  }
}