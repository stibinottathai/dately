import 'package:dately/features/counter/presentation/counter_screen.dart';
import 'package:dately/features/auth/presentation/sign_in_screen.dart';
import 'package:dately/features/auth/presentation/sign_up/steps/sign_up_step_1_screen.dart';
import 'package:dately/features/auth/presentation/sign_up/steps/sign_up_step_2_screen.dart';
import 'package:dately/features/auth/presentation/sign_up/steps/sign_up_step_3_screen.dart';
import 'package:dately/features/auth/presentation/sign_up/steps/sign_up_step_4_screen.dart';
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
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign-up/step-1',
        builder: (context, state) => const SignUpStep1Screen(),
      ),
      GoRoute(
        path: '/sign-up/step-2',
        builder: (context, state) => const SignUpStep2Screen(),
      ),
      GoRoute(
        path: '/sign-up/step-3',
        builder: (context, state) => const SignUpStep3Screen(),
      ),
      GoRoute(
        path: '/sign-up/step-4',
        builder: (context, state) => const SignUpStep4Screen(),
      ),
      GoRoute(
        path: '/counter',
        builder: (context, state) => const CounterScreen(),
      ),
    ],
  );
}
