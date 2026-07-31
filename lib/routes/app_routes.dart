import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../views/course_detail/course_detail_view.dart';
import '../views/facturation/facturation_view.dart';
import '../views/facturation/facture_client_view.dart';
import '../views/facturation/montants_courses_view.dart';
import '../views/facturation/recap_mensuel_view.dart';
import '../views/historique/historique_detail_view.dart';
import '../views/historique/historique_view.dart';
import '../views/home/home_view.dart';

/// Centralise les chemins de routes et la config du router.
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String details = '/details/:id';
  static const String historique = '/historique';
  static const String facturation = '/facturation';
  static const String facturationMontants = '/facturation/montants';
  static const String facturationFactureClient = '/facturation/facture-client';
  static const String facturationRecap = '/facturation/recap';
  static const String profile = '/profile';

  /// Helper pour construire l'URL de la route details avec un id.
  static String detailsPath(String id) => '/details/$id';

  /// Helper pour construire l'URL du détail d'une course dans l'historique.
  static String historiqueDetailsPath(String id) => '/historique/details/$id';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    debugLogDiagnostics: true, // logge la navigation dans la console, pratique en dev
    routes: [
      // StatefulShellRoute.indexedStack garde une pile de navigation
      // indépendante par onglet (chaque branche a son propre Navigator).
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Onglet 1 : Accueil (+ sa route de détails imbriquée)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: home,
                name: 'home',
                builder: (context, state) => const HomeView(),
                routes: [
                  GoRoute(
                    path: 'details/:id', // -> /details/:id, imbriqué sous /
                    name: 'details',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return CourseDetailView(courseId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Onglet 2 : Historique (+ sa route de détails imbriquée)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: historique,
                name: 'historique',
                builder: (context, state) => const HistoriqueView(),
                routes: [
                  GoRoute(
                    path: 'details/:id', // -> /historique/details/:id
                    name: 'historique-details',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return HistoriqueDetailView(courseId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Onglet 3 : Facturation (écran menu + 3 routes imbriquées)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: facturation,
                name: 'facturation',
                builder: (context, state) => const FacturationView(),
                routes: [
                  GoRoute(
                    path: 'montants', // -> /facturation/montants
                    name: 'facturation-montants',
                    builder: (context, state) => const MontantsCoursesView(),
                  ),
                  GoRoute(
                    path: 'facture-client', // -> /facturation/facture-client
                    name: 'facturation-facture-client',
                    builder: (context, state) => const FactureClientView(),
                  ),
                  GoRoute(
                    path: 'recap', // -> /facturation/recap
                    name: 'facturation-recap',
                    builder: (context, state) => const RecapMensuelView(),
                  ),
                ],
              ),
            ],
          ),
          // Onglet 4 : Profil
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: profile,
                name: 'profile',
                builder: (context, state) => const _ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route introuvable : ${state.uri}')),
    ),
  );
}

/// Scaffold partagé qui affiche la BottomNavigationBar et l'écran
/// courant fourni par le navigationShell (une des branches ci-dessus).
class _ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _ScaffoldWithNavBar({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          // index == index actuel -> revient à la racine de la branche
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Historique'),
          NavigationDestination(icon: Icon(Icons.euro), label: 'Facturation'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------
// Écran temporaire (Profil pas encore développé).
// À remplacer plus tard par la vraie vue dans lib/views/.
// -----------------------------------------------------------------------

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: const Center(child: Text('Écran de profil')),
    );
  }
}