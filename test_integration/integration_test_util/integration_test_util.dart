import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:graphql/client.dart';
import 'package:swing_venue/main.dart';
import 'package:swing_venue/providers/graphql_client.provider.dart';

class IntegrationTestUtil {

  //Code below is for setting a custom resolution for the test  
  /*
  final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized(); //used for custom resoulution - should be at the top of main

  //reset the screen size back to normal
  addTearDown(() async {
    await binding.setSurfaceSize(null); // Resets to default size
  });
  //await binding.setSurfaceSize(const Size(390, 844)); //we can use this at the beggining of test suite to simulate given resoulution
  */

  //must be called with await - app needs to be fully built before test can continue
  //use this when mocking the DB
  static Future<void> initializeAppWithMockedGraphQL(WidgetTester tester, GraphQLClient mockClient) async {
    var delegate = await LocalizationDelegate.create(
        fallbackLocale: 'en', supportedLocales: ['en']);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          graphqlClientProvider.overrideWithValue(mockClient),
        ],
        child: createApp(delegate),
      ),
    );
    await tester.pumpAndSettle();
  }

    //must be called with await - app needs to be fully built before test can continue
    //use this for E2E testing with real backend
  static Future<void> initializeApp(WidgetTester tester) async {
    var delegate = await LocalizationDelegate.create(
        fallbackLocale: 'en', supportedLocales: ['en']);

    await tester.pumpWidget(
      ProviderScope(
        child: createApp(delegate),
      ),
    );
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint(details.toString());
    };
    await tester.pumpAndSettle();
  }

  //methods below are used with static access to move around the app
  static Future<void> fillLoginFields(
      WidgetTester tester, String username, String password) async {
    final userNameField = find.byKey(Key('emailField'));
    final passwordField = find.byKey(Key('passwordField'));

    await tester.tap(userNameField);
    await tester.enterText(userNameField, username);
    await tester.pumpAndSettle();

    await tester.tap(passwordField);
    await tester.enterText(passwordField, password);
  }

  static Future<void> tapLoginButton(WidgetTester tester) async {
    final loginButton = find.byKey(Key('loginButton'));
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
  }

  static Future<void> performLogin(
      WidgetTester tester, String username, String password) async {
    await fillLoginFields(tester, username, password);
    await tapLoginButton(tester);
    await tapLoginButton(tester);
    await tester.pumpAndSettle();
  }

  static Future<void> tapLogoutButton(WidgetTester tester) async {
    final logoutButton = find.byKey(Key('logoutButton'));
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();
    final confirmLogoutButton = find.byKey(Key('confirmLogoutButton'));
    await tester.tap(confirmLogoutButton);
    await tester.pumpAndSettle();
  }
}
