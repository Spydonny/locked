import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/analytics/presentation/pages/analytics_page.dart';
import '../../features/auth/presentation/pages/auth_loading_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/exercises/presentation/pages/exercise_library_page.dart';
import '../../features/nutrition/presentation/pages/nutrition_page.dart';
import '../../features/physique/presentation/pages/physique_page.dart';
import '../../features/routines/presentation/pages/routines_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/social/presentation/pages/social_feed_page.dart';
import '../../features/sync/presentation/pages/import_sync_page.dart';
import '../../features/workout/presentation/pages/workout_page.dart';
import '../../shared/widgets/app_shell_frame.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

Stream<Object?> _vaultEvents(dynamic vault) async* {
  // Force one refresh tick immediately, then on every vault change.
  yield Object();
  yield* vault.changes;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final vault = ref.watch(authSessionVaultProvider);
  final refreshListenable = _RouterRefreshListenable(_vaultEvents(vault));
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final snapshot = vault.snapshot;
      final location = state.matchedLocation;
      final isAuthRoute = location.startsWith('/auth');
      final isSplashRoute = location == '/splash';

      debugPrint(
        '[GoRouter] redirect loc=$location hydrated=${snapshot.hydrated} authed=${snapshot.isAuthenticated}',
      );

      if (!snapshot.hydrated) {
        return isSplashRoute ? null : '/splash';
      }

      if (!snapshot.isAuthenticated) {
        return isAuthRoute ? null : '/auth/login';
      }

      if (isSplashRoute || isAuthRoute) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            const NoTransitionPage<void>(child: AuthLoadingPage()),
      ),
      GoRoute(
        path: '/auth/login',
        name: 'auth-login',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _authPage(key: state.pageKey, child: const SignInPage()),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'auth-register',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _authPage(key: state.pageKey, child: const RegisterPage()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShellFrame(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                name: 'dashboard',
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/social',
                name: 'social',
                builder: (context, state) => const SocialFeedPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/workout',
                name: 'workout',
                builder: (context, state) => const WorkoutPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                name: 'analytics',
                builder: (context, state) => const AnalyticsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/exercises',
        name: 'exercises',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ExerciseLibraryPage(),
      ),
      GoRoute(
        path: '/routines',
        name: 'routines',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RoutinesPage(),
      ),
      GoRoute(
        path: '/nutrition',
        name: 'nutrition',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NutritionPage(),
      ),
      GoRoute(
        path: '/physique',
        name: 'physique',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PhysiquePage(),
      ),
      GoRoute(
        path: '/sync',
        name: 'sync',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ImportSyncPage(),
      ),
    ],
  );
});

CustomTransitionPage<void> _authPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.02),
            end: Offset.zero,
          ).animate(fade),
          child: child,
        ),
      );
    },
  );
}

class _RouterRefreshListenable extends ChangeNotifier {
  _RouterRefreshListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
