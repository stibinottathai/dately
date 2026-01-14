import 'package:dately/features/counter/presentation/counter_screen.dart';
import 'package:dately/features/onboarding/presentation/onboarding_screen.dart';
import 'package:dately/features/splash/presentation/splash_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/counter',
        builder: (context, state) => const CounterScreen(),
      ),
    ],
  );
}
