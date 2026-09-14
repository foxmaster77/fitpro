import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/exercise_detail/exercise_detail_screen.dart';
import 'features/form_check/form_check_screen.dart';
import 'features/goals/goals_screen.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/paywall/paywall_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/routine_builder/routine_builder_screen.dart';
import 'features/telehealth/telehealth_screen.dart';
import 'features/workout/workout_screen.dart';
import 'state/app_session.dart';
import 'theme/app_theme.dart';
import 'widgets/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(appSessionProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/coach',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(appSessionProvider);
      final loc = state.matchedLocation;
      if (session.isLoading || session.hasError) {
        if (loc != '/boot') return '/boot';
        return null;
      }
      final onboarded = session.value!.profile.onboardingComplete;
      if (!onboarded && loc != '/onboarding') return '/onboarding';
      if (onboarded && (loc == '/onboarding' || loc == '/boot')) {
        return '/coach';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/boot', builder: (context, state) => const _BootScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/paywall',
        builder: (context, state) =>
            PaywallScreen(triggerReason: state.extra as String?),
      ),
      GoRoute(
        path: '/form-check',
        builder: (context, state) => const FormCheckScreen(),
      ),
      GoRoute(path: '/goals', builder: (context, state) => const GoalsScreen()),
      GoRoute(
        path: '/routine-builder',
        builder: (context, state) => const RoutineBuilderScreen(),
      ),
      GoRoute(
        path: '/exercise/:exerciseId',
        builder: (context, state) {
          final exerciseId = state.pathParameters['exerciseId']!;
          return ExerciseDetailScreen(exerciseId: exerciseId);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/coach',
                builder: (context, state) =>
                    const SafeArea(child: HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/log',
                builder: (context, state) =>
                    const SafeArea(child: WorkoutScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/rehab',
                builder: (context, state) =>
                    const SafeArea(child: TelehealthScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/you',
                builder: (context, state) =>
                    const SafeArea(child: ProfileScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class FitproApp extends ConsumerWidget {
  const FitproApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'FITPRO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}

class _BootScreen extends ConsumerWidget {
  const _BootScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);
    return Scaffold(
      body: Center(
        child: session.when(
          loading: () => const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Updating your encrypted vault…'),
            ],
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$error', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => ref.invalidate(appSessionProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (_) => const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
