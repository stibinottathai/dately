import 'package:dately/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
  });
}
