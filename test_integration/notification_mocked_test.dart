import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

import 'integration_test_util/graphql_integration_util.dart';
import 'integration_test_util/integration_test_util.dart';
import 'integration_test_util/notification_integration_util.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized(); //makes sure that the test framework is loaded and works
  
  late MockGraphQLClient mockGraphQLClient;
  setUpAll(() {
    registerFallbackValue(FakeMutationOptions()); 
  });
  setUp(() {
    mockGraphQLClient = MockGraphQLClient();
  });

  String username = 'test@example.com';
  String password = '1234';

group('notification mocked -', () {
  testWidgets('Go to notificationPage',(WidgetTester tester) async {
    IntegrationTestGraphUtil.setupRequiredMocks(tester, mockGraphQLClient, username, password);

    await IntegrationTestUtil.initializeAppWithMockedGraphQL(tester, mockGraphQLClient);
    await IntegrationTestUtil.performLogin(tester, username, password);
    await tester.pumpAndSettle();
 
    await NotificationTestIntegrationUtil.navigateToNotificationPage(tester);

    final notificationPage = find.byKey(Key('notificationPage'));
    expect(notificationPage, findsOneWidget, reason: 'did not navigate to notification page');
  });

  testWidgets('Verify no notification group selected error message',(WidgetTester tester) async {
    IntegrationTestGraphUtil.setupRequiredMocks(tester, mockGraphQLClient, username, password);

    await IntegrationTestUtil.initializeAppWithMockedGraphQL(tester, mockGraphQLClient);
    await NotificationTestIntegrationUtil.navigateToNotificationPage(tester);
    
    final sendNoticationButton = find.byKey(Key('sendNotificationButton'));
    await tester.tap(sendNoticationButton);

    await tester.pump(Duration(seconds: 1)); //wait 1 sec and look for error message
    final errorMessage = find.text('Please select the group to send to');

    expect(errorMessage, findsOneWidget, reason: 'correct error message is not shown');
  });

  testWidgets('Verify empty title and message error message',(WidgetTester tester) async {
    IntegrationTestGraphUtil.setupRequiredMocks(tester, mockGraphQLClient, username, password);

    await IntegrationTestUtil.initializeAppWithMockedGraphQL(tester, mockGraphQLClient);
    
    await NotificationTestIntegrationUtil.navigateToNotificationPage(tester);
    
    final followersButton = find.byKey(Key('followerButton'));
    await tester.tap(followersButton);
    
    final sendNoticationButton = find.byKey(Key('sendNotificationButton'));
    await tester.tap(sendNoticationButton);

    await tester.pump(Duration(seconds: 1)); //wait 1 sec and look for error message

    final errorMessageTitle = find.text('Please enter a title');
    expect(errorMessageTitle, findsOneWidget, reason: 'correct title error message is not shown');

    final errorMessageMessage = find.text('Please enter a message');
    expect(errorMessageMessage, findsOneWidget, reason: 'correct message error message is not shown');
  });

  testWidgets('Verify notification in confirm dialog',(WidgetTester tester) async {
    IntegrationTestGraphUtil.setupRequiredMocks(tester, mockGraphQLClient, username, password);

    await IntegrationTestUtil.initializeAppWithMockedGraphQL(tester, mockGraphQLClient);
    
    await NotificationTestIntegrationUtil.navigateToNotificationPage(tester);
    
    String message = "notification message";
    String title = "notification title";

    await NotificationTestIntegrationUtil.fillTitleAndMessageField(tester, title, message);

    final followersButton = find.byKey(Key('followerButton'));
    await tester.tap(followersButton);
    
    await NotificationTestIntegrationUtil.pressSendNotification(tester);

    final messageFinder = find.text('Confirm the Notification');
    expect(messageFinder, findsOneWidget, reason: "Notification creation did not reach the final confirmation dialog");

    final confirmTitle = find.byKey(Key("confirmTitle"));
    final confirmMessage = find.byKey(Key("confirmMessage"));

    expect((tester.widget<Text>(confirmTitle).data), title, reason: "The confirmation title does not match the provided title");
    expect((tester.widget<Text>(confirmMessage).data), message, reason: "The confirmation message does not match the provided message");
  });

  testWidgets('Verify succesfull sendNotification creation',(WidgetTester tester) async {
    IntegrationTestGraphUtil.setupRequiredMocks(tester, mockGraphQLClient, username, password);

    IntegrationTestGraphUtil.setupMockAnyMutation(mockGraphQLClient, {
      "__typename": "Mutation",
      "sendCustomNotification": true,
    });

    await IntegrationTestUtil.initializeAppWithMockedGraphQL(tester, mockGraphQLClient);
    await NotificationTestIntegrationUtil.navigateToNotificationPage(tester);
    
    String message = "notification message";
    String title = "notification title";

    await NotificationTestIntegrationUtil.fillTitleAndMessageField(tester, title, message);

    final followersButton = find.byKey(Key('followerButton'));
    await tester.tap(followersButton);
    
    await NotificationTestIntegrationUtil.pressSendNotification(tester);
    await tester.pump(Duration(seconds: 4)); //wait for the confirmation button to enable

    final confirmSendNotificationButton = find.byKey(Key('confirmSendNotificationButton'));
    await tester.tap(confirmSendNotificationButton);
    await tester.pumpAndSettle();
    await tester.pump(Duration(seconds: 1)); //wait for message to appear

    final successMessageFinder = find.text('Notification sent successfully!');
    expect(successMessageFinder, findsOneWidget, reason: "Notification sent successfully message was not shown in the UI.");
  });
});
}