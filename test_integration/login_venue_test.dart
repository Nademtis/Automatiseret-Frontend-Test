import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:integration_test/integration_test.dart';

import 'integration_test_util/integration_test_util.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized(); //makes sure that the test framework is loaded and works
  
  String correctUsername = '1234@1234.com';
  String correctPassword = '12341234';

  String wrongUsername = 'wrong_username@test.com';
  String wrongPassword = 'wrong_password';

group('loginVenue -', () {
  testWidgets('Login with wrong username', (WidgetTester tester) async {
    await IntegrationTestUtil.initializeApp(tester);

    await IntegrationTestUtil.fillLoginFields(tester, wrongUsername, correctPassword);
    
    final loginButton = find.byKey(Key('loginButton'));
    await tester.tap(loginButton);
    await tester.pump(Duration(seconds: 2));

    final errorMessageFinder = find.text('Opps, something went wrong, try again or contact support.');
    expect(errorMessageFinder, findsOneWidget, reason: "The correct error message is not shown in the GUI");
  });
  
  testWidgets('Login with wrong password', (WidgetTester tester) async {
    await IntegrationTestUtil.initializeApp(tester);

    await IntegrationTestUtil.fillLoginFields(tester, correctUsername, wrongPassword);
    
    final loginButton = find.byKey(Key('loginButton'));
    await tester.tap(loginButton);
    
    await tester.pump(Duration(seconds: 2));

    final errorMessageFinder = find.text(translate("pages.login.errors.invalid_credentials"));
    expect(errorMessageFinder, findsOneWidget, reason: "The correct error message is not shown in the GUI");
  });

  testWidgets('Login with empty username and password',(WidgetTester tester) async {
    await IntegrationTestUtil.initializeApp(tester);

    final loginButton = find.byKey(Key('loginButton'));
    await tester.tap(loginButton);

    await tester.pump(Duration(seconds: 2));

    final errorMessageFinder = find.text('Opps, something went wrong, try again or contact support.');
    expect(errorMessageFinder, findsOneWidget, reason: "The correct error message is not shown in the GUI");
  });

  testWidgets('Verify login with correct username and password',(WidgetTester tester) async {
    await IntegrationTestUtil.initializeApp(tester);

    await IntegrationTestUtil.performLogin(tester, correctUsername, correctPassword);
    await tester.pumpAndSettle();

    final dashboardKey = find.byKey(Key('dashboardPage'));
    expect(dashboardKey, findsOneWidget, reason: 'did not navigate to dashboard');
  });
});
}
