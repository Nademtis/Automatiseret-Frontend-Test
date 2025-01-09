import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'integration_test_util/integration_test_util.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final signupButton = find.byKey(Key('signupField'));
  final continueButton = find.byKey(Key('continueButton'));

  final passwordField = find.byKey(Key('passwordField'));
  final confirmPasswordField = find.byKey(Key('confirmPasswordField'));

  group('createVenue -', () {
    testWidgets('Confirm error messages', (WidgetTester tester) async {
      await IntegrationTestUtil.initializeApp(tester);

      await tester.tap(signupButton);
      await tester.pumpAndSettle();

      final nameError = find.text('Please enter a name');
      final phoneError = find.text('Please enter a phonenumber');
      final emailError = find.text('Please enter email');
      final passwordError = find.text('Please enter a password');

      await tester.ensureVisible(continueButton);
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      expect(nameError, findsOneWidget);
      expect(phoneError, findsOneWidget);
      expect(emailError, findsOneWidget);
      expect(passwordError, findsExactly(2));
    });

    testWidgets('Test incorrect password', (WidgetTester tester) async {
      await IntegrationTestUtil.initializeApp(tester);

      await tester.tap(signupButton);
      await tester.pumpAndSettle();

      await tester.ensureVisible(passwordField);
      await tester.enterText(passwordField, 'password');
      await tester.ensureVisible(confirmPasswordField);
      await tester.enterText(confirmPasswordField, 'password2');
      await tester.ensureVisible(continueButton);
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      final notSamePasswordError = find.text('Passwords does not match');
      expect(notSamePasswordError, findsOneWidget);
    });

    testWidgets('Test too short password', (WidgetTester tester) async {
      await IntegrationTestUtil.initializeApp(tester);

      await tester.tap(signupButton);
      await tester.pumpAndSettle();

      final passwordError = find.text('Password must be at least 6 characters long');
      await tester.ensureVisible(passwordField);
      await tester.enterText(passwordField, "pass");

      await tester.ensureVisible(confirmPasswordField);
      await tester.enterText(confirmPasswordField, 'pass');

      await tester.ensureVisible(continueButton);
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      expect(passwordError, findsAtLeast(2));
    });
  });
}