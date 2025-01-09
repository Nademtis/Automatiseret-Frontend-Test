import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'integration_test_util.dart';

class EventIntegrationUtil {
  static Future<void> navigateToEventPage(WidgetTester tester) async {
    await IntegrationTestUtil.performLogin(tester, "Integration@test.com", "12341234");
    await tester.pumpAndSettle();
    final eventMenuItem = find.byKey(Key('EventsPageRoute'));
    await tester.tap(eventMenuItem);
    await tester.pumpAndSettle();
  }

  static Future<void> navigateToCreateEventPage(WidgetTester tester) async {
    final createEventButton = find.byKey(Key('create_new_event_button'));
    await tester.tap(createEventButton);
    await tester.pumpAndSettle();
  }

  static Future<void> createEvent(
      WidgetTester tester, String eventName, String eventDescription) async {
    final createNewEventButton = find.byKey(Key('create_new_event_button'));
    await tester.tap(createNewEventButton);
    await tester.pumpAndSettle();

    final eventNameField = find.byKey(Key('event_name_field'));
    await tester.tap(eventNameField);
    await tester.enterText(eventNameField, eventName);
    await tester.pumpAndSettle();

    final eventDescriptionField = find.byKey(Key('event_description_field'));
    await tester.ensureVisible(eventDescriptionField);
    await tester.tap(eventDescriptionField);
    await tester.enterText(eventDescriptionField, eventDescription);
    await tester.pumpAndSettle();

    await _selectStartAndEndTime(tester);

    await _selectCategories(tester, ['Pub', 'Wine Bar']);
    await setAgeFilter(tester);

    final createEventButton = find.byKey(Key('create_event_button'));
    await tester.ensureVisible(createEventButton);
    await tester.tap(createEventButton);
    await tester.pumpAndSettle();

    final errorDialogBox = find.byKey(Key('confirmation_dialog'));
    if (tester.any(errorDialogBox)) {
      // Tap the OK button if the dialog is present
      await tester.tap(find.text('Yes, this is intentional'));
      await tester.pumpAndSettle();
    }
  }

  static Future<void> verifyEventInCarousel(WidgetTester tester, String eventName) async {
    final carouselKey = find.byKey(Key('event_carousel'));
    expect(carouselKey, findsOneWidget);

    bool found = false;
    final maxAttempts = 20;
    int attempts = 0;

    while (!found && attempts < maxAttempts) {
      final eventItems = find.descendant(
        of: carouselKey,
        matching: find.byType(GestureDetector),
      );

      for (final eventItem in eventItems.evaluate()) {
        final eventNameFinder = find.descendant(
          of: find.byWidget(eventItem.widget),
          matching: find.text(eventName),
        );

        if (find.text(eventName).evaluate().isNotEmpty) {
          found = true;
          break;
        } else {
          await tester.tap(find.byWidget(eventItem.widget));
          await tester.pumpAndSettle();
        }
      }

      if (!found) {
        await tester.drag(carouselKey, Offset(-200, 0));
        await tester.pumpAndSettle();
      }

      attempts++;
    }

    expect(found, isTrue, reason: '$eventName was not found in the carousel');
  }

  static Future<void> editEvent(
      WidgetTester tester, String oldName, String newName) async {
    await verifyEventInCarousel(tester, oldName);

    final manageEventButton = find.byKey(Key('manage_event_button'));
    await tester.tap(manageEventButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit Event'));
    await tester.pumpAndSettle();

    final editEventNameField = find.byKey(Key('edit_event_name_field'));
    await tester.tap(editEventNameField);
    await tester.enterText(editEventNameField, newName);
    await tester.pumpAndSettle();

    final saveChangesButton = find.byKey(Key('save_changes_button'));
    await tester.ensureVisible(saveChangesButton);
    await tester.tap(saveChangesButton);
    await tester.pumpAndSettle();

    expect(find.text(newName), findsAtLeast(1));
  }

  static Future<void> duplicateEvent(WidgetTester tester, String eventName, String newName, String newDescription) async {
    final manageEventButton = find.byKey(Key('manage_event_button'));
    await tester.tap(manageEventButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Duplicate Event'));
    await tester.pumpAndSettle();

    final eventNameField = find.byKey(Key('event_name_field'));
    await tester.tap(eventNameField);
    await tester.enterText(eventNameField, newName);
    await tester.pumpAndSettle();

    final eventDescriptionField = find.byKey(Key('event_description_field'));
    await tester.tap(eventDescriptionField);
    await tester.enterText(eventDescriptionField, newDescription);
    await tester.pumpAndSettle();

    await _selectStartAndEndTime(tester, daysOffset: 2);

    final createEventButton = find.byKey(Key('create_event_button'));
    await tester.ensureVisible(createEventButton);
    await tester.tap(createEventButton);
    await tester.pumpAndSettle();
  }

  static Future<void> deleteEvent(WidgetTester tester, String eventName) async {
    await verifyEventInCarousel(tester, eventName);

    final manageEventButton = find.byKey(Key('manage_event_button'));
    await tester.tap(manageEventButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete Event'));
    await tester.pumpAndSettle();
    await tester.pump(Duration(seconds: 5));
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    await tester.pump(Duration(seconds: 3));
  }

  static Future<void> _selectStartAndEndTime(WidgetTester tester, {int daysOffset = 1}) async {
    final startTimePicker = find.byKey(Key('start_time_picker'));
    await tester.ensureVisible(startTimePicker);
    expect(startTimePicker, findsOneWidget);
    await tester.tap(startTimePicker);
    await tester.pumpAndSettle();

    final DateTime selectedDate = DateTime.now().add(Duration(days: daysOffset));
    await tester.tap(find.text('${selectedDate.day}'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final endTimePicker = find.byKey(Key('end_time_picker'));
    await tester.ensureVisible(endTimePicker);
    expect(endTimePicker, findsOneWidget);
    await tester.tap(endTimePicker);
    await tester.pumpAndSettle();

    await tester.tap(find.text('${selectedDate.day}'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }

  static Future<void> _selectCategories(WidgetTester tester, List<String> categories) async {
    final categoryField = find.byKey(Key('category_selection_field'));
    await tester.ensureVisible(categoryField);
    await tester.tap(categoryField);
    await tester.pumpAndSettle();

    for (final category in categories) {
      final categoryFinder = find.byKey(Key(category));
      await tester.tap(categoryFinder);
      await tester.pumpAndSettle();
    }

    final saveCategoriesButton = find.byKey(Key('save_categories_button'));
    await tester.tap(saveCategoriesButton);
    await tester.pumpAndSettle();
  }

  static Future<void> setAgeFilter(WidgetTester tester) async {
    final rangeSlider = find.byKey(Key('age_filter'));
    await tester.ensureVisible(rangeSlider);
    expect(rangeSlider, findsOneWidget);

    final sliderRect = tester.getRect(rangeSlider);
    final startHandlePosition = Offset(sliderRect.left + 10, sliderRect.center.dy);
    await tester.dragFrom(startHandlePosition, Offset(130, 0));
    await tester.pumpAndSettle();

    final endHandlePosition = Offset(sliderRect.right - 10, sliderRect.center.dy);
    await tester.dragFrom(endHandlePosition, Offset(-130, 0));
    await tester.pumpAndSettle();
  }
}
