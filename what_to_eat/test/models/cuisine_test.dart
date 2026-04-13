import 'package:flutter_test/flutter_test.dart';
import 'package:what_to_eat/models/cuisine.dart';

void main() {
  group('Cuisine', () {
    test('has exactly 5 cuisines', () {
      expect(Cuisine.values.length, 5);
    });

    test('each cuisine has a non-empty display name', () {
      for (final cuisine in Cuisine.values) {
        expect(cuisine.displayName.isNotEmpty, true);
      }
    });

    test('each cuisine has a unique color', () {
      final colors = Cuisine.values.map((c) => c.color).toSet();
      expect(colors.length, 5);
    });

    test('each cuisine has a flag emoji', () {
      for (final cuisine in Cuisine.values) {
        expect(cuisine.flag.isNotEmpty, true);
      }
    });

    test('each cuisine has exactly 20 dishes', () {
      for (final cuisine in Cuisine.values) {
        expect(cuisine.dishes.length, 20,
            reason: '${cuisine.displayName} should have 20 dishes');
      }
    });

    test('each dish has a name and description', () {
      for (final cuisine in Cuisine.values) {
        for (final dish in cuisine.dishes) {
          expect(dish.name.isNotEmpty, true);
          expect(dish.description.isNotEmpty, true);
        }
      }
    });

    test('Korean cuisine has Korean BBQ as first dish', () {
      expect(Cuisine.korean.dishes.first.name, 'Korean BBQ');
    });
  });
}
