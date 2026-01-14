import 'package:dately/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:google_fonts/google_fonts.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Splash Screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.runAsync(() async {
      await tester.pumpWidget(const ProviderScope(child: App()));
      // Wait for splash screen
      await Future.delayed(const Duration(seconds: 4));
      // Re-pump to process navigation
      await tester.pumpAndSettle();
    });

    // Verify Onboarding Screen is displayed
    expect(find.text('Find Your Match'), findsOneWidget);

    // Skip onboarding
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    // Verify Sign In Screen is displayed
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);

    // Navigate to Sign Up
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    // Verify Step 1
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Basic Info'), findsOneWidget);

    // Verify we can go back
    await tester.tap(find.byIcon(Icons.arrow_back_ios));
    await tester.pumpAndSettle();
    expect(find.text('Sign In'), findsOneWidget);
  });
}
