import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class NotificationTestIntegrationUtil  {

  static Future<void> navigateToNotificationPage(WidgetTester tester) async {
    final dealMenuItem = find.byKey(Key('NotificationsPageRoute'));
    await tester.tap(dealMenuItem);
    await tester.pumpAndSettle();
  }
  
  static Future<void> pressSendNotification(WidgetTester tester) async {
    final button = find.byKey(Key('sendNotificationButton'));
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  static Future<void> fillTitleAndMessageField(WidgetTester tester, String title, String message) async {
    final titleField = find.byKey(Key('titleField'));
    final messageField = find.byKey(Key('messageField'));
    
    await tester.tap(titleField);
    await tester.enterText(titleField, title);
    await tester.pumpAndSettle();

    await tester.tap(messageField);
    await tester.enterText(messageField, message);
    await tester.pumpAndSettle();
  }
}