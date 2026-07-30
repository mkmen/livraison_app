import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../views/course_detail/course_detail_view.dart';
import '../views/home/home_view.dart';

/// Centralise les chemins de routes et la config du router.
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String details = '/details/:id';
  static const String search = '/search';
  static const String profile = '/profile';

  /// Helper pour construire l'URL de la route details avec un id.
  static String detailsPath(String id) => '/details/$id';

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
          // Onglet 2 : Recherche
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: search,
                name: 'search',
                builder: (context, state) => const _SearchScreen(),
              ),
            ],
          ),
          // Onglet 3 : Profil
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
/// courant fourni par le navigationShell (une des 3 branches ci-dessus).
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
          NavigationDestination(icon: Icon(Icons.search), label: 'Recherche'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------
// Écrans temporaires (Recherche / Profil pas encore développés).
// À remplacer plus tard par les vraies vues dans lib/views/.
// -----------------------------------------------------------------------

class _SearchScreen extends StatelessWidget {
  const _SearchScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recherche')),
      body: const Center(child: Text('Écran de recherche')),
    );
  }
}

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