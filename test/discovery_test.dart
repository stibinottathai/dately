import 'package:dately/features/discovery/presentation/discovery_screen.dart';
import 'package:dately/features/discovery/presentation/advanced_filters_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Discovery Screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: DiscoveryScreen()));

    // Verify header exists
    expect(find.text('Dately'), findsOneWidget);
    expect(find.text('_RK'), findsOneWidget);

    // Verify Card content
    expect(find.text('Sarah, 24'), findsOneWidget);
    expect(find.text('Brooklyn, 2 miles away'), findsOneWidget);

    // Verify Interests
    expect(find.text('Photography'), findsOneWidget);

    // Verify Action Buttons
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
  });

  testWidgets('Advanced Filters Screen smoke test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AdvancedFiltersScreen())),
    );

    // Verify Header
    expect(find.text('Advanced Filters'), findsOneWidget);

    // Verify Sections
    expect(find.text('Discovery Settings'), findsOneWidget);
    expect(find.text('I\'m interested in'), findsOneWidget);
    expect(find.text('Lifestyle'), findsOneWidget);

    // Verify Premium Section
    expect(find.text('Verified Profiles Only'), findsOneWidget);

    // Verify Button
    expect(find.text('Apply Filters'), findsOneWidget);
  });
}
