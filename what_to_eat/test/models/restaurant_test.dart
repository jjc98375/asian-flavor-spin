import 'package:flutter_test/flutter_test.dart';
import 'package:what_to_eat/models/restaurant.dart';

void main() {
  group('Restaurant', () {
    test('creates from Google Places API JSON', () {
      final json = {
        'displayName': {'text': 'Kang Ho Dong Baekjeong'},
        'rating': 4.8,
        'userRatingCount': 2140,
        'formattedAddress': '3465 W 6th St, Los Angeles, CA 90020',
        'location': {'latitude': 34.0635, 'longitude': -118.2980},
        'priceLevel': 'PRICE_LEVEL_MODERATE',
      };

      final restaurant = Restaurant.fromPlacesJson(json);

      expect(restaurant.name, 'Kang Ho Dong Baekjeong');
      expect(restaurant.rating, 4.8);
      expect(restaurant.reviewCount, 2140);
      expect(restaurant.address, '3465 W 6th St, Los Angeles, CA 90020');
      expect(restaurant.latitude, 34.0635);
      expect(restaurant.longitude, -118.2980);
      expect(restaurant.priceLevel, 2);
    });

    test('handles missing optional fields gracefully', () {
      final json = {
        'displayName': {'text': 'Some Place'},
        'location': {'latitude': 0.0, 'longitude': 0.0},
      };

      final restaurant = Restaurant.fromPlacesJson(json);

      expect(restaurant.name, 'Some Place');
      expect(restaurant.rating, 0.0);
      expect(restaurant.reviewCount, 0);
      expect(restaurant.address, '');
      expect(restaurant.priceLevel, 0);
    });

    test('priceLevelDisplay returns correct symbols', () {
      final r1 = Restaurant(
        name: 'A', rating: 4.0, reviewCount: 10, address: '',
        latitude: 0, longitude: 0, priceLevel: 1,
      );
      final r2 = Restaurant(
        name: 'B', rating: 4.0, reviewCount: 10, address: '',
        latitude: 0, longitude: 0, priceLevel: 2,
      );
      final r3 = Restaurant(
        name: 'C', rating: 4.0, reviewCount: 10, address: '',
        latitude: 0, longitude: 0, priceLevel: 3,
      );

      expect(r1.priceLevelDisplay, '\$');
      expect(r2.priceLevelDisplay, '\$\$');
      expect(r3.priceLevelDisplay, '\$\$\$');
    });
  });
}
