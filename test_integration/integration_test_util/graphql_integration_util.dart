import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:swing_venue/api/auth/input/request_venue_login_input.dart';
import 'package:swing_venue/api/auth/input/venue_login_input.dart';
import 'package:swing_venue/api/auth/mutations.dart';
import 'package:swing_venue/api/event/queries.dart';
import 'package:swing_venue/api/swing-profile/mutations.dart';
import 'package:swing_venue/api/venue/queries.dart';

class MockGraphQLClient extends Mock implements GraphQLClient {}

class FakeMutationOptions extends Fake implements MutationOptions<Object?> {}

class IntegrationTestGraphUtil {
  //use this when you know precicely what mutation is going to happen - and what the response should be.
  //this can be used multiple times within same test, since specific mutation document is given.
  static void setupMockSelectedMutation(MockGraphQLClient mockClient,
      MutationOptions options, Map<String, dynamic> mockResponseData) {
    when(() => mockClient.mutate(options)).thenAnswer((_) async {
      return QueryResult(
        data: mockResponseData,
        source: QueryResultSource.network,
        options: options,
      );
    });
  }

  //use when you don't know what mutation is going to happen. - cannot be used multiple times within same test
  static void setupMockAnyMutation(
      MockGraphQLClient mockClient, Map<String, dynamic> mockResponseData) {
    when(() => mockClient.mutate(any())).thenAnswer((invocation) async {
      return QueryResult(
        data: mockResponseData,
        source: QueryResultSource.network,
        options: invocation.positionalArguments.first,
      );
    });
  }

  //use when mocking a selected query
  static void setupMockSelectedQuery(MockGraphQLClient mockClient,
      QueryOptions options, Map<String, dynamic> mockResponseData) {
    when(() => mockClient.query(options)).thenAnswer((_) async {
      return QueryResult(
        data: mockResponseData,
        source: QueryResultSource.network,
        options: options,
      );
    });
  }

//verifies given mutation with a given body
  static void verifyMutationWithBody(MockGraphQLClient mockClient,
      dynamic expectedDocument, Map<String, dynamic> expectedBody) {
    final captured = verify(() => mockClient.mutate(captureAny())).captured;
    expect(captured.length, 1);
    final capturedOptions = captured.first as MutationOptions;
    expect(capturedOptions.document, equals(expectedDocument));
    expect(capturedOptions.variables, equals(expectedBody));
  }

//verifies given mutation
  static void verifyMutation(
      MockGraphQLClient mockClient, dynamic expectedDocument) {
    final captured = verify(() => mockClient.mutate(captureAny())).captured;
    expect(captured.length, 1);
    final capturedOptions = captured.first as MutationOptions;
    expect(capturedOptions.document, equals(expectedDocument));
  }

  //generates a mocked Jwt token/payload used in loginMutation
  static String generateMockJwtPayload() {
    final now = DateTime.now();
    final exp = now.add(Duration(hours: 1)).millisecondsSinceEpoch ~/
        1000; // Expiration in 1 hour
    final payload = {
      "userId": "mock_user_id_123", // Static or can be replaced with UUID
      "email": "1234@1234.com",
      "iat": now.millisecondsSinceEpoch ~/ 1000,
      "exp": exp, // Expiration time
    };
    return base64UrlEncode(utf8.encode(json.encode(payload)));
  }

  static void mockSendNotification(
      WidgetTester tester, MockGraphQLClient mockClient) async {
    final mockedBody = {
      "type": "Followers",
      "name": "Test Notification",
      "message": "This is a test notification message",
      "eventId": "123",
    };
    final mockedResponse = {
      "__typename": "Mutation",
      "sendCustomNotification": true,
    };
    MutationOptions options = MutationOptions(
      document: sendCustomNotificationMutation,
      variables: mockedBody,
    );
    IntegrationTestGraphUtil.setupMockSelectedMutation(
        mockClient, options, mockedResponse);
  }

  //methods below are helper methods to call in bigger tests where multiple mocking is required
  static void setupRequiredMocks(WidgetTester tester,
      MockGraphQLClient mockClient, String email, String password) async {
    //step 1 - requestlogin
    final mockedBody = RequestVenueLoginInput(email: email, password: password);
    const mockedResponse = {
      "requestVenueLogin": "123456",
    };
    MutationOptions options = MutationOptions(
      document: requestVenueLoginMutation,
      variables: {"input": mockedBody.toJson()},
    );

    IntegrationTestGraphUtil.setupMockSelectedMutation(mockClient, options, mockedResponse);

    //step 2 - login
    final mockedBody2 = VenueLoginInput(email: email, token: '123456');
    final mockedResponse2 = {
      "venueLogin":
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.${generateMockJwtPayload()}.mock_signature",
    };
    MutationOptions options2 = MutationOptions(
      document: venueLoginMutation,
      variables: {"input": mockedBody2.toJson()},
    );
    IntegrationTestGraphUtil.setupMockSelectedMutation(mockClient, options2, mockedResponse2);

    //fetch currentVenue
    const mockedResponse3 = {
      "getCurrentVenue": {
        "__typename": "VenueModel",
        "id": "venue_123",
        "email": "venue@example.com",
        "password": "hashed_password",
        "name": "Mocked Venue",
        "description": "A test venue for mock data.",
        "url": "https://example.com",
        "images": [],
        "address": {
          "__typename": "AutoCompleteAddressModel",
          "city": "Mock City",
          "countryCodeISO3": "MCK",
          "postalCode": "12345",
          "streetName": "Mock Street",
          "streetNumber": "42",
          "latitude": 12.345678,
          "longitude": 98.765432
        },
        "contactNumber": "+1234567890",
        "isPrivate": false,
        "isVerified": true,
        "openingHours": [
          {
            "__typename": "OpeningHoursModel",
            "day": "Monday",
            "from": "08:00",
            "to": "18:00"
          },
          {
            "__typename": "OpeningHoursModel",
            "day": "Tuesday",
            "from": "08:00",
            "to": "18:00"
          }
        ],
        "dealOfTheDay": {
          "__typename": "DealOfTheDayModel",
          "from": "2024-12-01T08:00:00Z",
          "to": "2024-12-01T18:00:00Z",
          "description": "50% off all items",
          "beforePrice": 100,
          "nowPrice": 50,
          "repeated": false,
          "usedBy": ["user_1", "user_2"]
        },
        "studentDiscount": {
          "__typename": "StudentDiscountModel",
          "createdAt": "2024-11-01T00:00:00Z",
          "updatedAt": "2024-12-01T00:00:00Z",
          "discount": 15
        }
      }
    };
    QueryOptions options3 = QueryOptions(
      document: getCurrentVenueQuery,
      //variables: {"input": mockedBody.toJson()},
    );
    IntegrationTestGraphUtil.setupMockSelectedQuery(
        mockClient, options3, mockedResponse3);

    //fetchEvents mock
    final mockEventsDataResponse = {
      'getMyVenueEvents': {
        'items': [],
        'total': 0,
        'hasMore': false,
      },
    };
    final eventQueryOptions = QueryOptions(
      document: myEventsQuery,
      variables: {"skip": 0, "take": 10},
    );
    IntegrationTestGraphUtil.setupMockSelectedQuery(mockClient, eventQueryOptions, mockEventsDataResponse);
  }
}
