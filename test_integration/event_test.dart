import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'integration_test_util/event_integration_util.dart';
import 'integration_test_util/integration_test_util.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized(); //makes sure that the test framework is loaded and works

  final phonePreview = find.byKey(Key('central_preview'));
  final loginButton = find.byKey(Key('loginButton'));

  group('event -', () {
    testWidgets('Everything is there', (WidgetTester tester) async {
      await IntegrationTestUtil.initializeApp(tester);
      await EventIntegrationUtil.navigateToEventPage(tester);

      expect(phonePreview, findsOneWidget);

      await IntegrationTestUtil.tapLogoutButton(tester);
      expect(loginButton, findsOneWidget);
    });

    testWidgets('Check for error messages', (WidgetTester tester) async {
      await IntegrationTestUtil.initializeApp(tester);
      await EventIntegrationUtil.navigateToEventPage(tester);

      await EventIntegrationUtil.navigateToCreateEventPage(tester);

      final createEventButton = find.byKey(Key('create_event_button'));
      await tester.ensureVisible(createEventButton);
      await tester.tap(createEventButton);
      await tester.pumpAndSettle();

      expect(find.text('Please enter event name'), findsOneWidget);
      expect(find.text('Please enter event details'), findsOneWidget);

      await IntegrationTestUtil.tapLogoutButton(tester);
      expect(loginButton, findsOneWidget);
    });

    testWidgets('RangeSlider handles can be dragged independently', (WidgetTester tester) async {
      await IntegrationTestUtil.initializeApp(tester);
      await EventIntegrationUtil.navigateToEventPage(tester);

      await EventIntegrationUtil.navigateToCreateEventPage(tester);

      // Drag the RangeSlider handles
      await EventIntegrationUtil.setAgeFilter(tester);

      await IntegrationTestUtil.tapLogoutButton(tester);
      expect(loginButton, findsOneWidget);
    });

    testWidgets('Create Event Full Test', (WidgetTester tester) async {
      await IntegrationTestUtil.initializeApp(tester);
      await EventIntegrationUtil.navigateToEventPage(tester);

      // Create a new event
      await EventIntegrationUtil.createEvent(tester, 'Test Event',
          'Test Description');

      final eventMenuItem = find.byKey(Key('EventsPageRoute'));
      await tester.tap(eventMenuItem);
      await tester.pumpAndSettle();

      // Verify event is visible in the carousel
      await EventIntegrationUtil.verifyEventInCarousel(tester, 'Test Event');

      // Edit the event
      await EventIntegrationUtil.editEvent(tester, 'Test Event',
          'Edited Test Event');

      // Duplicate the event
      await EventIntegrationUtil.duplicateEvent(tester, 'Edited Test Event',
          'Duplicated Event', 'Test Description Dup');

      // Delete the events
      await EventIntegrationUtil.deleteEvent(tester, 'Edited Test Event');
      await EventIntegrationUtil.deleteEvent(tester, 'Duplicated Event');

      // Verify events are deleted
      expect(find.text('Edited Test Event'), findsNothing);
      expect(find.text('Test Description Dup'), findsNothing);

      await IntegrationTestUtil.tapLogoutButton(tester);
      expect(loginButton, findsOneWidget);
    });
  });
}
