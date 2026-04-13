# What to Eat? Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Flutter mobile app that spins a roulette wheel to pick a cuisine, lets the user choose a dish type, then shows nearby restaurants ranked by rating using Google Places API.

**Architecture:** Client-only Flutter app with no backend. Three screens in a linear navigation flow (Spin → Dish → Results). Google Places API called directly from the device. GPS via geolocator package.

**Tech Stack:** Flutter/Dart, flutter_fortune_wheel, geolocator, google_maps_flutter, http, Google Places API (New)

**Spec:** `docs/superpowers/specs/2026-04-10-what-to-eat-design.md`

---

## File Structure

```
what_to_eat/
├── lib/
│   ├── main.dart                        # App entry, theme config, route definitions
│   ├── models/
│   │   ├── cuisine.dart                 # Cuisine enum with colors, flags, dish lists
│   │   └── restaurant.dart              # Restaurant data model from Places API
│   ├── services/
│   │   ├── location_service.dart        # GPS permission + current position
│   │   └── places_service.dart          # Google Places Text Search API client
│   ├── screens/
│   │   ├── spin_wheel_screen.dart       # Landing page with fortune wheel
│   │   ├── dish_selection_screen.dart   # Dish type grid + custom input
│   │   └── results_screen.dart          # List/Map toggle view with results
│   └── widgets/
│       ├── restaurant_card.dart         # Single restaurant list item
│       └── dish_card.dart               # Single dish option tile
├── test/
│   ├── models/
│   │   ├── cuisine_test.dart
│   │   └── restaurant_test.dart
│   └── services/
│       └── places_service_test.dart
├── pubspec.yaml
├── android/app/src/main/AndroidManifest.xml  # Location + internet permissions
└── ios/Runner/Info.plist                      # Location usage description
```

---

### Task 1: Scaffold Flutter Project

**Files:**
- Create: `what_to_eat/` (entire Flutter project scaffold)
- Modify: `what_to_eat/pubspec.yaml`

- [ ] **Step 1: Create Flutter project**

Run from the repo root:
```bash
flutter create what_to_eat --org com.whattoeat --platforms ios,android
```

Expected: Flutter project created at `what_to_eat/` with default counter app.

- [ ] **Step 2: Add dependencies to pubspec.yaml**

Replace the `dependencies` and `dev_dependencies` sections in `what_to_eat/pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_fortune_wheel: ^1.3.1
  geolocator: ^13.0.2
  google_maps_flutter: ^2.10.0
  http: ^1.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

- [ ] **Step 3: Install dependencies**

```bash
cd what_to_eat && flutter pub get
```

Expected: All packages resolved successfully.

- [ ] **Step 4: Verify project runs**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 5: Commit**

```bash
git add what_to_eat/
git commit -m "chore: scaffold Flutter project with dependencies"
```

---

### Task 2: Cuisine Model with Dish Data

**Files:**
- Create: `what_to_eat/lib/models/cuisine.dart`
- Test: `what_to_eat/test/models/cuisine_test.dart`

- [ ] **Step 1: Write the failing test**

Create `what_to_eat/test/models/cuisine_test.dart`:

```dart
import 'package:flutter/material.dart';
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
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd what_to_eat && flutter test test/models/cuisine_test.dart
```

Expected: FAIL — `package:what_to_eat/models/cuisine.dart` not found.

- [ ] **Step 3: Write the Cuisine model**

Create `what_to_eat/lib/models/cuisine.dart`:

```dart
import 'package:flutter/material.dart';

class Dish {
  final String name;
  final String description;
  final String emoji;

  const Dish({
    required this.name,
    required this.description,
    required this.emoji,
  });
}

enum Cuisine {
  korean(
    displayName: 'Korean',
    flag: '🇰🇷',
    color: Color(0xFFFF6B6B),
    dishes: [
      Dish(name: 'Korean BBQ', description: 'Tabletop grilled marinated meats', emoji: '🔥'),
      Dish(name: 'Bibimbap', description: 'Rice bowl with vegetables, egg', emoji: '🍚'),
      Dish(name: 'Bulgogi', description: 'Sweet marinated grilled beef', emoji: '🥩'),
      Dish(name: 'Japchae', description: 'Stir-fried glass noodles, vegetables', emoji: '🍜'),
      Dish(name: 'Tteokbokki', description: 'Spicy chewy rice cakes', emoji: '🌶️'),
      Dish(name: 'Sundubu Jjigae', description: 'Soft tofu spicy stew', emoji: '🥘'),
      Dish(name: 'Doenjang Jjigae', description: 'Fermented soybean paste stew', emoji: '🫕'),
      Dish(name: 'Kimchi Jjigae', description: 'Spicy kimchi pork stew', emoji: '🥘'),
      Dish(name: 'Galbi', description: 'Grilled marinated short ribs', emoji: '🥩'),
      Dish(name: 'Samgyeopsal', description: 'Grilled thick-cut pork belly', emoji: '🥓'),
      Dish(name: 'Dakgalbi', description: 'Spicy stir-fried chicken', emoji: '🍗'),
      Dish(name: 'Haemul Pajeon', description: 'Seafood green onion pancake', emoji: '🥞'),
      Dish(name: 'Bossam', description: 'Boiled pork with lettuce wraps', emoji: '🥬'),
      Dish(name: 'Jajangmyeon', description: 'Noodles in black bean sauce', emoji: '🍝'),
      Dish(name: 'Naengmyeon', description: 'Cold buckwheat noodle soup', emoji: '🍜'),
      Dish(name: 'Gamjatang', description: 'Spicy pork spine stew', emoji: '🍲'),
      Dish(name: 'Soondubu', description: 'Silken tofu hot pot', emoji: '🫕'),
      Dish(name: 'Korean Fried Chicken', description: 'Double-fried crispy glazed chicken', emoji: '🍗'),
      Dish(name: 'Gimbap', description: 'Korean seaweed rice rolls', emoji: '🍙'),
      Dish(name: 'Kongnamul Bap', description: 'Soybean sprout rice bowl', emoji: '🌱'),
    ],
  ),
  chinese(
    displayName: 'Chinese',
    flag: '🇨🇳',
    color: Color(0xFFFFA94D),
    dishes: [
      Dish(name: "General Tso's Chicken", description: 'Sweet crispy fried chicken', emoji: '🍗'),
      Dish(name: 'Kung Pao Chicken', description: 'Spicy peanut stir-fried chicken', emoji: '🥜'),
      Dish(name: 'Lo Mein', description: 'Soft stir-fried egg noodles', emoji: '🍜'),
      Dish(name: 'Fried Rice', description: 'Wok-tossed rice, eggs, vegetables', emoji: '🍚'),
      Dish(name: 'Dim Sum', description: 'Assorted small steamed dumplings', emoji: '🥟'),
      Dish(name: 'Peking Duck', description: 'Lacquered crispy roasted duck', emoji: '🦆'),
      Dish(name: 'Mapo Tofu', description: 'Spicy silken tofu, ground pork', emoji: '🌶️'),
      Dish(name: 'Orange Chicken', description: 'Sweet citrus glazed fried chicken', emoji: '🍊'),
      Dish(name: 'Beef with Broccoli', description: 'Stir-fried beef, oyster sauce', emoji: '🥦'),
      Dish(name: 'Mongolian Beef', description: 'Savory sweet sliced flank steak', emoji: '🥩'),
      Dish(name: 'Hot and Sour Soup', description: 'Tangy spicy broth, tofu', emoji: '🍲'),
      Dish(name: 'Egg Drop Soup', description: 'Silky chicken broth, egg ribbons', emoji: '🥚'),
      Dish(name: 'Spring Rolls', description: 'Crispy fried vegetable rolls', emoji: '🌯'),
      Dish(name: 'Egg Foo Young', description: 'Chinese-style egg omelette', emoji: '🍳'),
      Dish(name: 'Sesame Chicken', description: 'Glazed chicken, sesame seeds', emoji: '🍗'),
      Dish(name: 'Dan Dan Noodles', description: 'Spicy Sichuan noodles, pork', emoji: '🍜'),
      Dish(name: 'Soup Dumplings', description: 'Steamed dumplings with broth', emoji: '🥟'),
      Dish(name: 'Scallion Pancake', description: 'Flaky fried green onion flatbread', emoji: '🫓'),
      Dish(name: 'Chow Mein', description: 'Crispy stir-fried noodles', emoji: '🍜'),
      Dish(name: 'Char Siu', description: 'Sweet roasted Cantonese pork', emoji: '🍖'),
    ],
  ),
  vietnamese(
    displayName: 'Vietnamese',
    flag: '🇻🇳',
    color: Color(0xFF69DB7C),
    dishes: [
      Dish(name: 'Pho', description: 'Slow-simmered beef noodle soup', emoji: '🍜'),
      Dish(name: 'Banh Mi', description: 'Crusty baguette Vietnamese sandwich', emoji: '🥖'),
      Dish(name: 'Bun Bo Hue', description: 'Spicy lemongrass beef noodles', emoji: '🍜'),
      Dish(name: 'Com Tam', description: 'Broken rice with grilled pork', emoji: '🍚'),
      Dish(name: 'Fresh Spring Rolls', description: 'Rice paper shrimp herb rolls', emoji: '🌯'),
      Dish(name: 'Bun Rieu', description: 'Crab tomato vermicelli soup', emoji: '🦀'),
      Dish(name: 'Banh Xeo', description: 'Sizzling crispy Vietnamese crepe', emoji: '🥞'),
      Dish(name: 'Bun Thit Nuong', description: 'Vermicelli grilled pork bowl', emoji: '🥗'),
      Dish(name: 'Ca Phe Sua Da', description: 'Vietnamese iced condensed milk coffee', emoji: '☕'),
      Dish(name: 'Bo Luc Lac', description: 'Shaking beef cubes, watercress', emoji: '🥩'),
      Dish(name: 'Chao', description: 'Slow-cooked savory rice congee', emoji: '🍲'),
      Dish(name: 'Mi Quang', description: 'Turmeric-stained noodles, pork shrimp', emoji: '🍜'),
      Dish(name: 'Cha Gio', description: 'Crispy pork vermicelli rolls', emoji: '🌯'),
      Dish(name: 'Hu Tieu', description: 'Clear pork seafood noodle soup', emoji: '🍜'),
      Dish(name: 'Banh Cuon', description: 'Steamed rice rolls with pork', emoji: '🥟'),
      Dish(name: 'Suon Nuong', description: 'Grilled lemongrass pork chop', emoji: '🍖'),
      Dish(name: 'Lau', description: 'Vietnamese tableside broth pot', emoji: '🫕'),
      Dish(name: 'Bun Mam', description: 'Fermented fish noodle soup', emoji: '🍜'),
      Dish(name: 'Banh Bao', description: 'Steamed pork-filled buns', emoji: '🥟'),
      Dish(name: 'Banh Canh', description: 'Thick tapioca udon-style soup', emoji: '🍲'),
    ],
  ),
  japanese(
    displayName: 'Japanese',
    flag: '🇯🇵',
    color: Color(0xFF74C0FC),
    dishes: [
      Dish(name: 'Sushi', description: 'Raw fish rice or sliced', emoji: '🍣'),
      Dish(name: 'Ramen', description: 'Rich broth wheat noodle soup', emoji: '🍜'),
      Dish(name: 'Tempura', description: 'Light battered deep-fried shrimp', emoji: '🍤'),
      Dish(name: 'Tonkatsu', description: 'Breaded deep-fried pork cutlet', emoji: '🍖'),
      Dish(name: 'Miso Soup', description: 'Fermented soybean broth, tofu', emoji: '🍲'),
      Dish(name: 'Udon', description: 'Thick wheat noodles in broth', emoji: '🍜'),
      Dish(name: 'Soba', description: 'Buckwheat noodles, cold or hot', emoji: '🍜'),
      Dish(name: 'Gyoza', description: 'Pan-fried pork dumplings', emoji: '🥟'),
      Dish(name: 'Edamame', description: 'Salted steamed soybean pods', emoji: '🫛'),
      Dish(name: 'Teriyaki', description: 'Sweet glazed grilled protein', emoji: '🍗'),
      Dish(name: 'Yakitori', description: 'Skewered charcoal-grilled chicken', emoji: '🍢'),
      Dish(name: 'Donburi', description: 'Protein over rice bowl', emoji: '🍚'),
      Dish(name: 'Takoyaki', description: 'Grilled octopus batter balls', emoji: '🐙'),
      Dish(name: 'Okonomiyaki', description: 'Savory Japanese pancake, cabbage', emoji: '🥞'),
      Dish(name: 'Karaage', description: 'Japanese crispy fried chicken', emoji: '🍗'),
      Dish(name: 'Chirashi', description: 'Scattered sashimi over sushi rice', emoji: '🍣'),
      Dish(name: 'Onigiri', description: 'Triangular seasoned rice balls', emoji: '🍙'),
      Dish(name: 'Shabu-Shabu', description: 'Swirled thin-sliced hot pot', emoji: '🫕'),
      Dish(name: 'Ebi Fry', description: 'Panko-breaded fried shrimp', emoji: '🍤'),
      Dish(name: 'Matcha Desserts', description: 'Green tea ice cream, cake', emoji: '🍵'),
    ],
  ),
  thai(
    displayName: 'Thai',
    flag: '🇹🇭',
    color: Color(0xFFDA77F2),
    dishes: [
      Dish(name: 'Pad Thai', description: 'Stir-fried rice noodles, tamarind', emoji: '🍜'),
      Dish(name: 'Tom Yum Soup', description: 'Spicy lemongrass shrimp soup', emoji: '🍲'),
      Dish(name: 'Green Curry', description: 'Coconut milk herb chicken curry', emoji: '🍛'),
      Dish(name: 'Red Curry', description: 'Spicy coconut red chili curry', emoji: '🌶️'),
      Dish(name: 'Massaman Curry', description: 'Mild peanut potato beef curry', emoji: '🍛'),
      Dish(name: 'Pad See Ew', description: 'Wide rice noodles, egg, broccoli', emoji: '🍜'),
      Dish(name: 'Thai Fried Rice', description: 'Jasmine rice wok-tossed protein', emoji: '🍚'),
      Dish(name: 'Tom Kha Gai', description: 'Coconut galangal chicken soup', emoji: '🥥'),
      Dish(name: 'Panang Curry', description: 'Rich thick peanut-lime curry', emoji: '🍛'),
      Dish(name: 'Larb', description: 'Minced meat lime herb salad', emoji: '🥗'),
      Dish(name: 'Papaya Salad', description: 'Shredded green papaya, chili', emoji: '🥗'),
      Dish(name: 'Mango Sticky Rice', description: 'Sweet coconut rice, fresh mango', emoji: '🥭'),
      Dish(name: 'Pad Kra Pao', description: 'Holy basil stir-fry, fried egg', emoji: '🍳'),
      Dish(name: 'Thai Spring Rolls', description: 'Crispy vegetable filled rolls', emoji: '🌯'),
      Dish(name: 'Satay', description: 'Grilled peanut sauce skewers', emoji: '🍢'),
      Dish(name: 'Drunken Noodles', description: 'Spicy wide noodles, basil', emoji: '🍜'),
      Dish(name: 'Khao Soi', description: 'Northern Thai coconut curry noodles', emoji: '🍜'),
      Dish(name: 'Crying Tiger', description: 'Grilled beef, spicy dipping sauce', emoji: '🥩'),
      Dish(name: 'Thai Basil Fried Rice', description: 'Aromatic basil wok fried rice', emoji: '🍚'),
      Dish(name: 'Tod Man Pla', description: 'Thai fish cakes, cucumber relish', emoji: '🐟'),
    ],
  );

  final String displayName;
  final String flag;
  final Color color;
  final List<Dish> dishes;

  const Cuisine({
    required this.displayName,
    required this.flag,
    required this.color,
    required this.dishes,
  });
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd what_to_eat && flutter test test/models/cuisine_test.dart
```

Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add what_to_eat/lib/models/cuisine.dart what_to_eat/test/models/cuisine_test.dart
git commit -m "feat: add Cuisine model with 20 dishes per cuisine"
```

---

### Task 3: Restaurant Model

**Files:**
- Create: `what_to_eat/lib/models/restaurant.dart`
- Test: `what_to_eat/test/models/restaurant_test.dart`

- [ ] **Step 1: Write the failing test**

Create `what_to_eat/test/models/restaurant_test.dart`:

```dart
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
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd what_to_eat && flutter test test/models/restaurant_test.dart
```

Expected: FAIL — `package:what_to_eat/models/restaurant.dart` not found.

- [ ] **Step 3: Write the Restaurant model**

Create `what_to_eat/lib/models/restaurant.dart`:

```dart
class Restaurant {
  final String name;
  final double rating;
  final int reviewCount;
  final String address;
  final double latitude;
  final double longitude;
  final int priceLevel;

  const Restaurant({
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.priceLevel,
  });

  factory Restaurant.fromPlacesJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>;
    final displayName = json['displayName'] as Map<String, dynamic>?;

    final priceLevelStr = json['priceLevel'] as String? ?? '';
    final priceLevel = switch (priceLevelStr) {
      'PRICE_LEVEL_FREE' => 0,
      'PRICE_LEVEL_INEXPENSIVE' => 1,
      'PRICE_LEVEL_MODERATE' => 2,
      'PRICE_LEVEL_EXPENSIVE' => 3,
      'PRICE_LEVEL_VERY_EXPENSIVE' => 4,
      _ => 0,
    };

    return Restaurant(
      name: displayName?['text'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['userRatingCount'] as int? ?? 0,
      address: json['formattedAddress'] as String? ?? '',
      latitude: (location['latitude'] as num).toDouble(),
      longitude: (location['longitude'] as num).toDouble(),
      priceLevel: priceLevel,
    );
  }

  String get priceLevelDisplay {
    if (priceLevel <= 0) return '';
    return '\$' * priceLevel;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd what_to_eat && flutter test test/models/restaurant_test.dart
```

Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add what_to_eat/lib/models/restaurant.dart what_to_eat/test/models/restaurant_test.dart
git commit -m "feat: add Restaurant model with Places API JSON parsing"
```

---

### Task 4: Location Service

**Files:**
- Create: `what_to_eat/lib/services/location_service.dart`
- Modify: `what_to_eat/android/app/src/main/AndroidManifest.xml`
- Modify: `what_to_eat/ios/Runner/Info.plist`

- [ ] **Step 1: Write the location service**

Create `what_to_eat/lib/services/location_service.dart`:

```dart
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceException('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationServiceException('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationServiceException(
        'Location permissions are permanently denied. Please enable them in Settings.',
      );
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }
}

class LocationServiceException implements Exception {
  final String message;
  const LocationServiceException(this.message);

  @override
  String toString() => message;
}
```

- [ ] **Step 2: Add Android location permission**

In `what_to_eat/android/app/src/main/AndroidManifest.xml`, add inside `<manifest>` before `<application>`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

- [ ] **Step 3: Add iOS location permission**

In `what_to_eat/ios/Runner/Info.plist`, add inside `<dict>`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>What to Eat needs your location to find nearby restaurants.</string>
```

- [ ] **Step 4: Verify no analysis errors**

```bash
cd what_to_eat && flutter analyze
```

Expected: No issues found.

- [ ] **Step 5: Commit**

```bash
git add what_to_eat/lib/services/location_service.dart what_to_eat/android/app/src/main/AndroidManifest.xml what_to_eat/ios/Runner/Info.plist
git commit -m "feat: add location service with GPS permission handling"
```

---

### Task 5: Places API Service

**Files:**
- Create: `what_to_eat/lib/services/places_service.dart`
- Test: `what_to_eat/test/services/places_service_test.dart`

- [ ] **Step 1: Write the failing test**

Create `what_to_eat/test/services/places_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:what_to_eat/models/restaurant.dart';
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
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd what_to_eat && flutter test test/services/places_service_test.dart
```

Expected: FAIL — `package:what_to_eat/services/places_service.dart` not found.

- [ ] **Step 3: Write the Places service**

Create `what_to_eat/lib/services/places_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';

class PlacesService {
  final String apiKey;

  const PlacesService({required this.apiKey});

  static const _baseUrl =
      'https://places.googleapis.com/v1/places:searchText';

  Future<List<Restaurant>> searchRestaurants({
    required String dishType,
    required double latitude,
    required double longitude,
  }) async {
    final body = buildRequestBody(
      query: '$dishType restaurant',
      latitude: latitude,
      longitude: longitude,
    );

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask':
            'places.displayName,places.rating,places.userRatingCount,'
                'places.formattedAddress,places.location,places.priceLevel',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw PlacesServiceException(
        'Places API error: ${response.statusCode} ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return parseResponse(json);
  }

  static Map<String, dynamic> buildRequestBody({
    required String query,
    required double latitude,
    required double longitude,
  }) {
    return {
      'textQuery': query,
      'locationBias': {
        'circle': {
          'center': {
            'latitude': latitude,
            'longitude': longitude,
          },
          'radius': 8000.0, // 8km (~5 miles)
        },
      },
      'priceLevels': [
        'PRICE_LEVEL_INEXPENSIVE',
        'PRICE_LEVEL_MODERATE',
      ],
      'maxResultCount': 10,
    };
  }

  static List<Restaurant> parseResponse(Map<String, dynamic> json) {
    final places = json['places'] as List<dynamic>?;
    if (places == null) return [];

    final restaurants = places
        .map((p) => Restaurant.fromPlacesJson(p as Map<String, dynamic>))
        .toList();

    restaurants.sort((a, b) => b.rating.compareTo(a.rating));

    return restaurants;
  }
}

class PlacesServiceException implements Exception {
  final String message;
  const PlacesServiceException(this.message);

  @override
  String toString() => message;
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd what_to_eat && flutter test test/services/places_service_test.dart
```

Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add what_to_eat/lib/services/places_service.dart what_to_eat/test/services/places_service_test.dart
git commit -m "feat: add Places API service with text search and response parsing"
```

---

### Task 6: App Theme and Entry Point

**Files:**
- Modify: `what_to_eat/lib/main.dart`

- [ ] **Step 1: Write main.dart with theme and routing**

Replace `what_to_eat/lib/main.dart` entirely:

```dart
import 'package:flutter/material.dart';
import 'screens/spin_wheel_screen.dart';

void main() {
  runApp(const WhatToEatApp());
}

class WhatToEatApp extends StatelessWidget {
  const WhatToEatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'What to Eat?',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFAF7F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B6B),
          surface: const Color(0xFFFAF7F5),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D2D2D),
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D2D2D),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Color(0xFF2D2D2D),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFF999999),
          ),
        ),
        useMaterial3: true,
      ),
      home: const SpinWheelScreen(),
    );
  }
}
```

- [ ] **Step 2: Create placeholder screen so it compiles**

Create `what_to_eat/lib/screens/spin_wheel_screen.dart` with a placeholder:

```dart
import 'package:flutter/material.dart';

class SpinWheelScreen extends StatelessWidget {
  const SpinWheelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Spin Wheel — coming next')),
    );
  }
}
```

- [ ] **Step 3: Verify it compiles**

```bash
cd what_to_eat && flutter analyze
```

Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add what_to_eat/lib/main.dart what_to_eat/lib/screens/spin_wheel_screen.dart
git commit -m "feat: add app theme and entry point with design system colors"
```

---

### Task 7: Spin Wheel Screen

**Files:**
- Modify: `what_to_eat/lib/screens/spin_wheel_screen.dart`

- [ ] **Step 1: Write the full spin wheel screen**

Replace `what_to_eat/lib/screens/spin_wheel_screen.dart`:

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import '../models/cuisine.dart';
import 'dish_selection_screen.dart';

class SpinWheelScreen extends StatefulWidget {
  const SpinWheelScreen({super.key});

  @override
  State<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen> {
  final StreamController<int> _selectedController = StreamController<int>();
  bool _isSpinning = false;
  Cuisine? _selectedCuisine;

  @override
  void dispose() {
    _selectedController.close();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning) return;
    setState(() {
      _isSpinning = true;
      _selectedCuisine = null;
    });
    final selected = Fortune.randomInt(0, Cuisine.values.length);
    _selectedController.add(selected);
  }

  void _onAnimationEnd() {
    final index = Fortune.randomInt(0, Cuisine.values.length);
    setState(() {
      _isSpinning = false;
      _selectedCuisine = Cuisine.values[_lastSelected];
    });
  }

  int _lastSelected = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text(
              'What to Eat?',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Spin the wheel to pick a cuisine',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Wheel
            SizedBox(
              height: 280,
              child: FortuneWheel(
                selected: _selectedController.stream,
                animateFirst: false,
                duration: const Duration(seconds: 4),
                onAnimationEnd: () {
                  setState(() {
                    _isSpinning = false;
                    _selectedCuisine = Cuisine.values[_lastSelected];
                  });
                },
                onFling: _spin,
                indicators: const [
                  FortuneIndicator(
                    alignment: Alignment.topCenter,
                    child: TriangleIndicator(
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                ],
                items: [
                  for (int i = 0; i < Cuisine.values.length; i++)
                    FortuneItem(
                      style: FortuneItemStyle(
                        color: Cuisine.values[i].color,
                        borderColor: Colors.white,
                        borderWidth: 2,
                      ),
                      onTap: () {
                        _lastSelected = i;
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 48),
                        child: Text(
                          Cuisine.values[i].flag,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Spin button
            GestureDetector(
              onTap: _spin,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFDA77F2)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B6B).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'TAP TO SPIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Result display
            if (_selectedCuisine != null) ...[
              Text(
                '${_selectedCuisine!.flag} ${_selectedCuisine!.displayName}!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _selectedCuisine!.color,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DishSelectionScreen(
                        cuisine: _selectedCuisine!,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedCuisine!.color,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Let's go!",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],

            const Spacer(),

            // Cuisine chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: Cuisine.values.map((c) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: c.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${c.flag} ${c.displayName}',
                      style: TextStyle(
                        color: c.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Create placeholder DishSelectionScreen so it compiles**

Create `what_to_eat/lib/screens/dish_selection_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/cuisine.dart';

class DishSelectionScreen extends StatelessWidget {
  final Cuisine cuisine;

  const DishSelectionScreen({super.key, required this.cuisine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Dishes for ${cuisine.displayName} — coming next')),
    );
  }
}
```

- [ ] **Step 3: Verify it compiles**

```bash
cd what_to_eat && flutter analyze
```

Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add what_to_eat/lib/screens/
git commit -m "feat: add spin wheel screen with fortune wheel animation"
```

---

### Task 8: Dish Card Widget

**Files:**
- Create: `what_to_eat/lib/widgets/dish_card.dart`

- [ ] **Step 1: Write the dish card widget**

Create `what_to_eat/lib/widgets/dish_card.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/cuisine.dart';

class DishCard extends StatelessWidget {
  final Dish dish;
  final VoidCallback onTap;

  const DishCard({super.key, required this.dish, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(dish.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              dish.name,
              style: const TextStyle(
                color: Color(0xFF2D2D2D),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify it compiles**

```bash
cd what_to_eat && flutter analyze
```

Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add what_to_eat/lib/widgets/dish_card.dart
git commit -m "feat: add dish card widget"
```

---

### Task 9: Dish Selection Screen

**Files:**
- Modify: `what_to_eat/lib/screens/dish_selection_screen.dart`

- [ ] **Step 1: Write the full dish selection screen**

Replace `what_to_eat/lib/screens/dish_selection_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/cuisine.dart';
import '../widgets/dish_card.dart';
import 'results_screen.dart';

class DishSelectionScreen extends StatefulWidget {
  final Cuisine cuisine;

  const DishSelectionScreen({super.key, required this.cuisine});

  @override
  State<DishSelectionScreen> createState() => _DishSelectionScreenState();
}

class _DishSelectionScreenState extends State<DishSelectionScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToResults(String dishType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultsScreen(
          cuisine: widget.cuisine,
          dishType: dishType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 12),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  '← Spin again',
                  style: TextStyle(
                    color: widget.cuisine.color,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You spun...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '${widget.cuisine.flag} ${widget.cuisine.displayName}',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: widget.cuisine.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'What sounds good?',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                ],
              ),
            ),

            // Dish grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: widget.cuisine.dishes.length + 1, // +1 for custom
                  itemBuilder: (context, index) {
                    if (index < widget.cuisine.dishes.length) {
                      final dish = widget.cuisine.dishes[index];
                      return DishCard(
                        dish: dish,
                        onTap: () => _navigateToResults(dish.name),
                      );
                    }
                    // "Type your own" card
                    return GestureDetector(
                      onTap: () => _showCustomDishDialog(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFCCCCCC),
                            width: 1.5,
                            strokeAlign: BorderSide.strokeAlignInside,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('✏️', style: TextStyle(fontSize: 28)),
                            SizedBox(height: 6),
                            Text(
                              'Type your own',
                              style: TextStyle(
                                color: Color(0xFF999999),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search a dish type...',
                    hintStyle: TextStyle(color: Color(0xFFCCCCCC)),
                    prefixIcon: Icon(Icons.search, color: Color(0xFFCCCCCC)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      _navigateToResults(value.trim());
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomDishDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Type your dish'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Tteokbokki',
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.pop(ctx);
              _navigateToResults(value.trim());
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(ctx);
                _navigateToResults(controller.text.trim());
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Create placeholder ResultsScreen so it compiles**

Create `what_to_eat/lib/screens/results_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/cuisine.dart';

class ResultsScreen extends StatelessWidget {
  final Cuisine cuisine;
  final String dishType;

  const ResultsScreen({
    super.key,
    required this.cuisine,
    required this.dishType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Results for $dishType — coming next')),
    );
  }
}
```

- [ ] **Step 3: Verify it compiles**

```bash
cd what_to_eat && flutter analyze
```

Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add what_to_eat/lib/screens/dish_selection_screen.dart what_to_eat/lib/screens/results_screen.dart what_to_eat/lib/widgets/dish_card.dart
git commit -m "feat: add dish selection screen with grid and custom input"
```

---

### Task 10: Restaurant Card Widget

**Files:**
- Create: `what_to_eat/lib/widgets/restaurant_card.dart`

- [ ] **Step 1: Write the restaurant card widget**

Create `what_to_eat/lib/widgets/restaurant_card.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/restaurant.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final int rank;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.rank,
  });

  Color get _rankColor {
    return switch (rank) {
      1 => const Color(0xFFFF6B6B),
      2 => const Color(0xFFFFA94D),
      3 => const Color(0xFF69DB7C),
      _ => const Color(0xFF74C0FC),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Food icon placeholder
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFECD2), Color(0xFFFCB69F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('🍽️', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        restaurant.name,
                        style: const TextStyle(
                          color: Color(0xFF2D2D2D),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _rankColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#$rank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '⭐ ${restaurant.rating} · ${restaurant.reviewCount} reviews',
                  style: const TextStyle(
                    color: Color(0xFFF59E0B),
                    fontSize: 12,
                  ),
                ),
                Text(
                  restaurant.priceLevelDisplay.isNotEmpty
                      ? restaurant.priceLevelDisplay
                      : '',
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Verify it compiles**

```bash
cd what_to_eat && flutter analyze
```

Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add what_to_eat/lib/widgets/restaurant_card.dart
git commit -m "feat: add restaurant card widget with rank badge"
```

---

### Task 11: Results Screen (List + Map Views)

**Files:**
- Modify: `what_to_eat/lib/screens/results_screen.dart`

- [ ] **Step 1: Write the full results screen**

Replace `what_to_eat/lib/screens/results_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/cuisine.dart';
import '../models/restaurant.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';
import '../widgets/restaurant_card.dart';

class ResultsScreen extends StatefulWidget {
  final Cuisine cuisine;
  final String dishType;

  const ResultsScreen({
    super.key,
    required this.cuisine,
    required this.dishType,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _showMap = false;
  bool _isLoading = true;
  String? _error;
  List<Restaurant> _restaurants = [];
  double? _userLat;
  double? _userLng;

  // TODO: Replace with your actual API key
  static const _apiKey = String.fromEnvironment('PLACES_API_KEY');

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final locationService = LocationService();
      final position = await locationService.getCurrentPosition();
      _userLat = position.latitude;
      _userLng = position.longitude;

      final placesService = PlacesService(apiKey: _apiKey);
      final restaurants = await placesService.searchRestaurants(
        dishType: widget.dishType,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      setState(() {
        _restaurants = restaurants;
        _isLoading = false;
      });
    } on LocationServiceException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } on PlacesServiceException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 12),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  '← Change dish',
                  style: TextStyle(
                    color: widget.cuisine.color,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.dishType,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '📍 Near you · Under \$50/person',
                    style: TextStyle(color: Color(0xFF999999), fontSize: 13),
                  ),
                ],
              ),
            ),

            // Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0ECE8),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    _buildToggle('📋 List', !_showMap, () {
                      setState(() => _showMap = false);
                    }),
                    _buildToggle('🗺️ Map', _showMap, () {
                      setState(() => _showMap = true);
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildError()
                      : _restaurants.isEmpty
                          ? _buildEmpty()
                          : _showMap
                              ? _buildMapView()
                              : _buildListView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? const Color(0xFF2D2D2D) : const Color(0xFF999999),
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: _restaurants.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return RestaurantCard(
          restaurant: _restaurants[index],
          rank: index + 1,
        );
      },
    );
  }

  Widget _buildMapView() {
    if (_userLat == null || _userLng == null) {
      return const Center(child: Text('Location not available'));
    }

    final markers = <Marker>{};
    for (int i = 0; i < _restaurants.length; i++) {
      final r = _restaurants[i];
      markers.add(
        Marker(
          markerId: MarkerId('restaurant_$i'),
          position: LatLng(r.latitude, r.longitude),
          infoWindow: InfoWindow(
            title: '#${i + 1} ${r.name}',
            snippet: '⭐ ${r.rating} · ${r.priceLevelDisplay}',
          ),
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(_userLat!, _userLng!),
        zoom: 13,
      ),
      markers: markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      padding: const EdgeInsets.only(bottom: 80),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😕', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF999999), fontSize: 15),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadResults,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🍽️', style: TextStyle(fontSize: 48)),
            SizedBox(height: 16),
            Text(
              'No restaurants found nearby.\nTry a different dish type.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF999999), fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify it compiles**

```bash
cd what_to_eat && flutter analyze
```

Expected: No issues found (possibly warnings about API key — that's expected).

- [ ] **Step 3: Commit**

```bash
git add what_to_eat/lib/screens/results_screen.dart what_to_eat/lib/widgets/restaurant_card.dart
git commit -m "feat: add results screen with list and map views"
```

---

### Task 12: Platform Configuration (API Keys + Maps)

**Files:**
- Modify: `what_to_eat/android/app/src/main/AndroidManifest.xml`
- Modify: `what_to_eat/ios/Runner/AppDelegate.swift`

- [ ] **Step 1: Add Google Maps API key to Android**

In `what_to_eat/android/app/src/main/AndroidManifest.xml`, add inside `<application>`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

- [ ] **Step 2: Add Google Maps API key to iOS**

In `what_to_eat/ios/Runner/AppDelegate.swift`, add the import and API key setup:

```swift
import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

- [ ] **Step 3: Document how to pass the Places API key at runtime**

The app reads the Places API key via `String.fromEnvironment('PLACES_API_KEY')`. Run the app with:

```bash
flutter run --dart-define=PLACES_API_KEY=your_actual_key_here
```

- [ ] **Step 4: Commit**

```bash
git add what_to_eat/android/ what_to_eat/ios/
git commit -m "chore: add Google Maps platform configuration"
```

---

### Task 13: End-to-End Smoke Test

- [ ] **Step 1: Run all unit tests**

```bash
cd what_to_eat && flutter test
```

Expected: All tests pass.

- [ ] **Step 2: Run static analysis**

```bash
cd what_to_eat && flutter analyze
```

Expected: No issues found.

- [ ] **Step 3: Launch on simulator/device**

```bash
cd what_to_eat && flutter run --dart-define=PLACES_API_KEY=your_key_here
```

Manual verification checklist:
- [ ] Spin wheel screen loads with 5 colored segments and flag emojis
- [ ] Tapping "TAP TO SPIN" spins the wheel with smooth animation
- [ ] Wheel lands on a random cuisine, shows cuisine name and "Let's go!" button
- [ ] Dish selection screen shows 20 dish cards in a 2x2 grid + "Type your own"
- [ ] "← Spin again" navigates back to wheel
- [ ] Tapping a dish card navigates to results
- [ ] Results screen shows loading indicator, then restaurant cards ranked by rating
- [ ] List/Map toggle switches between list view and Google Maps view
- [ ] Map shows pins for each restaurant and blue dot for user location
- [ ] "← Change dish" navigates back to dish selection
- [ ] Error states display correctly (no internet, no location permission)

- [ ] **Step 4: Final commit**

```bash
git add -A
git commit -m "feat: complete What to Eat? v1 — spin wheel, dish selection, restaurant results"
```
