import 'package:dately/features/auth/presentation/forgot_password_screen.dart';
import 'package:dately/features/auth/presentation/sign_in_screen.dart';
import 'package:dately/features/auth/presentation/sign_up/steps/sign_up_step_1_screen.dart';
import 'package:dately/features/auth/presentation/sign_up/steps/sign_up_step_2_screen.dart';
import 'package:dately/features/auth/presentation/sign_up/steps/sign_up_step_3_screen.dart';
import 'package:dately/features/auth/presentation/sign_up/steps/sign_up_step_4_screen.dart';
import 'package:dately/features/main/presentation/main_screen.dart';
import 'package:dately/features/messages/presentation/chat_screen.dart';

import 'package:dately/features/profile/domain/user_profile.dart';
import 'package:dately/features/profile/presentation/edit_profile_screen.dart';
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
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
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
      GoRoute(path: '/counter', redirect: (context, state) => '/main/0'),
      GoRoute(path: '/likes', redirect: (context, state) => '/main/1'),
      GoRoute(path: '/messages', redirect: (context, state) => '/main/2'),
      GoRoute(path: '/profile', redirect: (context, state) => '/main/3'),
      GoRoute(
        path: '/main/:index',
        builder: (context, state) {
          final index = int.tryParse(state.pathParameters['index'] ?? '0') ?? 0;
          return MainScreen(initialIndex: index);
        },
      ),
      GoRoute(
        path: '/chat/:conversationId',
        builder: (context, state) {
          final conversationId = state.pathParameters['conversationId']!;
          final conversationData = state.extra;
          return ChatScreen(
            conversationId: conversationId,
            conversationData: conversationData,
          );
        },
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) {
          final profile = state.extra as UserProfile;
          return EditProfileScreen(profile: profile);
        },
      ),
    ],
  );
}
