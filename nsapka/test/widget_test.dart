// Tests pour l'application N'SAPKA

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nsapka/main.dart';

void main() {
  testWidgets('NSapkaApp should build without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NSapkaApp());

    // Verify that the app builds successfully
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('App should start with OnboardingScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NSapkaApp());
    await tester.pumpAndSettle();

    // Verify that we start with the onboarding screen
    // Look for the app name
    expect(find.text("N'SAPKA"), findsWidgets);
  });
}
