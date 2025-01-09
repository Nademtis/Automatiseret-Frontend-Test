import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/intl.dart';
import 'package:swing_venue/utils/is_deal_active.dart';

import 'integration_test_util/deal_integration_util.dart';
import 'integration_test_util/integration_test_util.dart';


Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  String username = '1234@1234.com';
  String password = '12341234';

  group('deal -', () {
    testWidgets('Go to Dealpage from dashboard through navbar', (WidgetTester tester) async {
      await IntegrationTestUtil.initializeApp(tester);
      await DealIntegrationUtil.navigateToDealPage(tester, username, password);

      final dealPage = find.byKey(Key('dealPage'));
      expect(dealPage, findsOneWidget, reason: 'not navigating to deal page correctly through navBar');
    });
  
    testWidgets('Go to createDealPage from dashboard through navbar', (WidgetTester tester) async {
      await IntegrationTestUtil.initializeApp(tester);

      final dealMenuItem = find.byKey(Key('DealsPageRoute'));
      expect(dealMenuItem, findsOneWidget, reason: 'navBar dealButton need to exist');

      await tester.tap(dealMenuItem);
      await tester.pumpAndSettle();

      final dealPage = find.byKey(Key('dealPage'));
      expect(dealPage, findsOneWidget, reason: 'not navigating to deal page correctly through navBar');

      final createDealButton = find.byKey(Key('createDealButton'));
      expect(createDealButton, findsOneWidget, reason: 'createNewDealButton needs to exist');

      await tester.tap(createDealButton);
      await tester.pumpAndSettle();

      final createDealPage = find.byKey(Key('createDealPage'));
      expect(createDealPage, findsOneWidget, reason: 'not navigating to deal page correctly with call2action button on dashboard');
    });

    testWidgets('Go to createDealPage from dashboard through call2action button', (WidgetTester tester) async {
      await IntegrationTestUtil.initializeApp(tester);

      final createDealDashboardButton = find.byKey(Key('createDealButtonDashboard'));
      await tester.tap(createDealDashboardButton);
      await tester.pumpAndSettle();

      final createDealPage = find.byKey(Key('createDealPage'));
      expect(createDealPage, findsOneWidget, reason: 'not navigating to deal page correctly with call2action button on dashboard');
    });

    testWidgets('Create deal - check create deal button exist', (WidgetTester tester) async {
      await IntegrationTestUtil.initializeApp(tester);
      await DealIntegrationUtil.navigateToCreateDealPageLoggedIn(tester);

      final validateDealButton = find.byKey(Key('validateDealButton'));
      expect(validateDealButton, findsOneWidget, reason: 'cannot find the validate deal button. can also have the text "create deal"');
    });

    testWidgets('Create deal - check empty inputfield error messsages', (WidgetTester tester) async{
      await IntegrationTestUtil.initializeApp(tester);
      await DealIntegrationUtil.navigateToCreateDealPageLoggedIn(tester);
      
      final validateDealButton = find.byKey(Key('validateDealButton'));
      await tester.tap(validateDealButton);
      await tester.pumpAndSettle();

      final errorMissingDescription = find.text('Please enter a description');
      final errorMissingOriginalPrice = find.text('Please enter the original price');
      final errorMissingNewPrice = find.text('Please enter the new price');

      expect(errorMissingDescription, findsOneWidget, reason: 'missing "description" error message');
      expect(errorMissingOriginalPrice, findsOneWidget, reason: 'missing "original price" error message');
      expect(errorMissingNewPrice, findsOneWidget, reason: 'missing "new price" error message');

    });
    testWidgets('Create deal - check empty time error messsages', (WidgetTester tester) async{
      await IntegrationTestUtil.initializeApp(tester);
      await DealIntegrationUtil.navigateToCreateDealPageLoggedIn(tester);
      
      await DealIntegrationUtil.fillDealDescriptionAndPrices(tester, "test desc", "100", "50");

      await DealIntegrationUtil.pressValidateDealButton(tester);

      final errorMissingTimeInput = find.text('Please fill out the start and end time');
      expect(errorMissingTimeInput, findsOneWidget, reason: 'missing correct error message');
    });
    
    testWidgets('Create deal - new price > old price', (WidgetTester tester) async{
      await IntegrationTestUtil.initializeApp(tester);
      await DealIntegrationUtil.navigateToCreateDealPageLoggedIn(tester);
      
      await DealIntegrationUtil.fillDealDescriptionAndPrices(tester, "test desc", "50", "100");

      await DealIntegrationUtil.pressValidateDealButton(tester);

      final errorMissingTimeInput = find.text('Can\'t be larger then the Original Price');
      expect(errorMissingTimeInput, findsOneWidget, reason: 'missing correct error message');
    });
    
     testWidgets('Create deal - start deal with startTime before now', (WidgetTester tester) async{
      await IntegrationTestUtil.initializeApp(tester);
      await DealIntegrationUtil.navigateToCreateDealPageLoggedIn(tester);

      await DealIntegrationUtil.fillDealDescriptionAndPrices(tester, "test desc", "100", "50");

      DateTime _startTime = DateTime.now().subtract(Duration(hours: 1)); //1 hour before now
      DateTime _endTime = DateTime.now().add(Duration(minutes:300 - DateTime.now().minute)); //defaults timeInput to rounded hour +4
      final formattedStartTime = DateFormat('HH').format(_startTime);
      final formattedEndTime = DateFormat('HH').format(_endTime);

      await DealIntegrationUtil.fillTimeSlot(tester, true, formattedStartTime, '00');
      await DealIntegrationUtil.fillTimeSlot(tester, false, formattedEndTime, '00');

      await DealIntegrationUtil.pressValidateDealButton(tester);

      final errorMessageFinder = find.text('You can\'t start a deal before now');
      expect(errorMessageFinder, findsOneWidget, reason: 'missing correct error message');
    });

    testWidgets('Create deal - cannot end deal after closingHours', (WidgetTester tester) async{
        await IntegrationTestUtil.initializeApp(tester);
        await DealIntegrationUtil.navigateToCreateDealPageLoggedIn(tester);

        await DealIntegrationUtil.fillDealDescriptionAndPrices(tester, "test desc", "100", "50");

        DateTime _startTime = DateTime.now().add(Duration(minutes:60 - DateTime.now().minute)); //defaults timeInput to rounded hour
        //DateTime _endTime = DateTime.now().add(Duration(minutes:300 - DateTime.now().minute)); //defaults timeInput to rounded hour +4
        final formattedStartTime = DateFormat('HH').format(_startTime);
        //final formattedEndTime = DateFormat('HH').format(_endTime);

        await DealIntegrationUtil.fillTimeSlot(tester, true, formattedStartTime, '00');
        await DealIntegrationUtil.fillTimeSlot(tester, false, '02', '00');

        await DealIntegrationUtil.pressValidateDealButton(tester);

        final errorMessageFinder = find.text('Your venue closes at 22:00, so you can\'t end the deal at 02:00');
        expect(errorMessageFinder, findsOneWidget, reason: 'missing correct error message');
    });

    testWidgets('Create deal - cannot start deal before openinghours', (WidgetTester tester) async{
        await IntegrationTestUtil.initializeApp(tester);
        await DealIntegrationUtil.navigateToCreateDealPageLoggedIn(tester);

        await DealIntegrationUtil.fillDealDescriptionAndPrices(tester, "test desc", "100", "50");

        //DateTime _startTime = DateTime.now().add(Duration(minutes:60 - DateTime.now().minute)); //defaults timeInput to rounded hour
        DateTime _endTime = DateTime.now().add(Duration(minutes:300 - DateTime.now().minute)); //defaults timeInput to rounded hour +4
        //final formattedStartTime = DateFormat('HH').format(_startTime);
        final formattedEndTime = DateFormat('HH').format(_endTime);

        final tomorrowButton = find.byKey(Key('tomorrowButton'));
        await tester.tap(tomorrowButton);
        await tester.pumpAndSettle();

        await DealIntegrationUtil.fillTimeSlot(tester, true, '08', '00');
        await DealIntegrationUtil.fillTimeSlot(tester, false, formattedEndTime, '00');

        await DealIntegrationUtil.pressValidateDealButton(tester);

        final errorMessageFinder = find.text('Your venue opens at 12:00, so you can\'t start the deal at 08:00');
        expect(errorMessageFinder, findsOneWidget, reason: 'missing correct error message');
    });

    testWidgets('Create deal - successfull creation', (WidgetTester tester) async{
      await IntegrationTestUtil.initializeApp(tester);
      await DealIntegrationUtil.navigateToCreateDealPageLoggedIn(tester);

      final description = "test desc";
      final oldPrice = "100";
      final newPrice = "50";

      await DealIntegrationUtil.fillDealDescriptionAndPrices(tester, description, oldPrice, newPrice);

      DateTime _startTime = DateTime.now().add(Duration(minutes: 1));
      DateTime _endTime = DateTime.now().add(Duration(minutes: 2));

      final formattedStartTimeHour = DateFormat('HH').format(_startTime);
      final formattedStartTimeMinute = DateFormat('mm').format(_startTime);

      final formattedEndTimeHour = DateFormat('HH').format(_endTime);
      final formattedEndTimeMinute = DateFormat('mm').format(_endTime);

      await DealIntegrationUtil.fillTimeSlot(tester, true, formattedStartTimeHour, formattedStartTimeMinute);
      await DealIntegrationUtil.fillTimeSlot(tester, false, formattedEndTimeHour, formattedEndTimeMinute);

      await DealIntegrationUtil.pressValidateDealButton(tester);

      final messageFinder = find.text('Confirm the Deal');
      expect(messageFinder, findsOneWidget, reason: "Deal creation did not reach the final confirmation dialog");

      final descFinder = find.text(description);
      expect(descFinder, findsWidgets, reason: "description is not shown");

      final timeSlotFinder = find.text('Today from $formattedStartTimeHour:$formattedStartTimeMinute to $formattedEndTimeHour:$formattedEndTimeMinute');
      expect(timeSlotFinder, findsOneWidget, reason: 'start and endtime is not shown');

      final confirmDealButton = find.byKey(Key('confirmDealButton'));
      expect(confirmDealButton, findsOneWidget, reason: 'confirm the deal button is not found');

      await tester.pump(Duration(seconds: 4));
      await tester.tap(confirmDealButton);
      await tester.pumpAndSettle();

      final dealOnDashbard = find.text(IsDealActive.getDealTimeText(_startTime, _endTime));
      expect(dealOnDashbard, findsOneWidget, reason: 'created deal is not correctly shown on dashboard');
  });
  });
  }
