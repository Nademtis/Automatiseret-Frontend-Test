import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'integration_test_util/integration_test_util.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  String correctUsername = '1234@1234.com';
  String correctPassword = '12341234';

group('navigation -', () {
  testWidgets('Get to dashboard', (WidgetTester tester) async{
    await IntegrationTestUtil.initializeApp(tester);
    await IntegrationTestUtil.performLogin(tester, correctUsername, correctPassword);
    await tester.pumpAndSettle();

    final dashboardKey = find.byKey(Key('dashboardPage'));
    expect(dashboardKey, findsOneWidget, reason: 'did not navigate to dashboard');
  });

  testWidgets('Get to notificationPage', (WidgetTester tester) async{
    await IntegrationTestUtil.initializeApp(tester);

    final dealMenuItem = find.byKey(Key('NotificationsPageRoute'));
    await tester.tap(dealMenuItem);
    await tester.pumpAndSettle();

    final notificationPage = find.byKey(Key('notificationPage'));
    expect(notificationPage, findsOneWidget, reason: 'did not navigate to notificationPage');
  });

  testWidgets('Get to eventPage', (WidgetTester tester) async{
    await IntegrationTestUtil.initializeApp(tester);

    final dealMenuItem = find.byKey(Key('EventsPageRoute'));
    await tester.tap(dealMenuItem);
    await tester.pumpAndSettle();
    await tester.pump(Duration(seconds: 2)); //inorder for events to load in

    final eventPage = find.byKey(Key('eventPage'));
    expect(eventPage, findsOneWidget, reason: 'did not navigate to eventPage');
  });

  testWidgets('Get to dealPage', (WidgetTester tester) async{
    await IntegrationTestUtil.initializeApp(tester);

    final dealMenuItem = find.byKey(Key('DealsPageRoute'));
    await tester.tap(dealMenuItem);
    await tester.pumpAndSettle();

    final dealPage = find.byKey(Key('dealPage'));
    expect(dealPage, findsOneWidget, reason: 'did not navigate to dealPage');
  });
  
  testWidgets('Log in - log out', (WidgetTester tester) async{
    await IntegrationTestUtil.initializeApp(tester);

    final dashboardKey = find.byKey(Key('dashboardPage'));
    expect(dashboardKey, findsOneWidget, reason: 'did not navigate to dashboard');

    await IntegrationTestUtil.tapLogoutButton(tester);
    
    final loginPageKey = find.byKey(Key('loginPage'));
    expect(loginPageKey, findsOneWidget, reason: 'did not logout and returned to loginPage correctly');
  });
});
}
