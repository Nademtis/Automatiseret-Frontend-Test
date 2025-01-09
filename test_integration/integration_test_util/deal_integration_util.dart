import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'integration_test_util.dart';

class DealIntegrationUtil {
  static Future<void> navigateToDealPage(WidgetTester tester, String username, String password) async {
    await IntegrationTestUtil.performLogin(tester, username, password);
    await tester.pumpAndSettle();
    final dealMenuItem = find.byKey(Key('DealsPageRoute'));
    await tester.tap(dealMenuItem);
    await tester.pumpAndSettle();
  }

  static Future<void> navigateToCreateDealPage(WidgetTester tester, String username, String password) async {
    await navigateToDealPage(tester, username, password);
    await tester.pumpAndSettle();
    final createNewDealButton = find.byKey(Key('createDealButton'));
    await tester.tap(createNewDealButton);
    await tester.pumpAndSettle();
  }

  static Future<void> navigateToCreateDealPageLoggedIn(WidgetTester tester) async {
    final createNewDealButton = find.byKey(Key('createDealButtonDashboard'));
    await tester.tap(createNewDealButton);
    await tester.pumpAndSettle();
  }

  static Future<void> fillDealDescriptionAndPrices(WidgetTester tester, String description, String originalPrice, String newPrice ) async {
    final descriptionField = find.byKey(Key('dealDescription'));
    final originalPriceField = find.byKey(Key('dealOriginalPrice'));
    final newPriceField = find.byKey(Key('dealNewPrice'));

    await tester.tap(descriptionField);
    await tester.enterText(descriptionField, description);
    await tester.pumpAndSettle();

    await tester.tap(originalPriceField);
    await tester.enterText(originalPriceField, originalPrice);
    await tester.pumpAndSettle();

    await tester.tap(newPriceField);
    await tester.enterText(newPriceField, newPrice);
    await tester.pumpAndSettle();
  }

  static Future<void> fillTimeSlot(WidgetTester tester, bool isStartTime, String hour, String minute) async {

    final timeField = isStartTime ? find.byKey(Key('startTimeField')) : find.byKey(Key('endTimeField'));
    
    await tester.tap(timeField);
    await tester.pumpAndSettle();

    final hourInputField = find.descendant(
        of: find.byType(TimePickerDialog), 
        matching: find.byType(TextField),
      ).first;

    final minuteInputField = find.descendant(
        of: find.byType(TimePickerDialog), 
        matching: find.byType(TextField),
      ).last;

    await tester.enterText(hourInputField, hour);
    await tester.pumpAndSettle();

    await tester.enterText(minuteInputField, minute);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'OK'));
    await tester.pumpAndSettle();
  }
  static Future<void> pressValidateDealButton(WidgetTester tester) async {
    final validateDealButton = find.byKey(Key('validateDealButton'));
    await tester.tap(validateDealButton);
    await tester.pumpAndSettle();
  }

}
