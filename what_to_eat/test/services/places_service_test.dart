import 'package:flutter_test/flutter_test.dart';
import 'package:what_to_eat/services/places_service.dart';

void main() {
  group('PlacesService', () {
    test('parseResponse extracts restaurants from API JSON', () {
      final responseBody = {
        'places': [
          {
            'displayName': {'text': 'Restaurant A'},
            'rating': 4.5,
            'userRatingCount': 100,
            'formattedAddress': '123 Main St',
            'location': {'latitude': 34.0, 'longitude': -118.0},
            'priceLevel': 'PRICE_LEVEL_MODERATE',
          },
          {
            'displayName': {'text': 'Restaurant B'},
            'rating': 4.2,
            'userRatingCount': 50,
            'formattedAddress': '456 Oak Ave',
            'location': {'latitude': 34.1, 'longitude': -118.1},
            'priceLevel': 'PRICE_LEVEL_INEXPENSIVE',
          },
        ],
      };

      final restaurants = PlacesService.parseResponse(responseBody);

      expect(restaurants.length, 2);
      expect(restaurants[0].name, 'Restaurant A');
      expect(restaurants[0].rating, 4.5);
      expect(restaurants[1].name, 'Restaurant B');
    });

    test('parseResponse returns empty list when no places', () {
      final responseBody = <String, dynamic>{};
      final restaurants = PlacesService.parseResponse(responseBody);
      expect(restaurants, isEmpty);
    });

    test('parseResponse sorts by rating descending', () {
      final responseBody = {
        'places': [
          {
            'displayName': {'text': 'Low'},
            'rating': 3.0,
            'userRatingCount': 10,
            'formattedAddress': '',
            'location': {'latitude': 0.0, 'longitude': 0.0},
          },
          {
            'displayName': {'text': 'High'},
            'rating': 4.9,
            'userRatingCount': 10,
            'formattedAddress': '',
            'location': {'latitude': 0.0, 'longitude': 0.0},
          },
        ],
      };

      final restaurants = PlacesService.parseResponse(responseBody);

      expect(restaurants[0].name, 'High');
      expect(restaurants[1].name, 'Low');
    });

    test('buildRequestBody creates correct JSON', () {
      final body = PlacesService.buildRequestBody(
        query: 'Korean BBQ restaurant',
        latitude: 34.0635,
        longitude: -118.2980,
      );

      expect(body['textQuery'], 'Korean BBQ restaurant');
      expect(body['locationBias']['circle']['center']['latitude'], 34.0635);
      expect(body['priceLevels'], contains('PRICE_LEVEL_INEXPENSIVE'));
      expect(body['priceLevels'], contains('PRICE_LEVEL_MODERATE'));
    });
  });
}
