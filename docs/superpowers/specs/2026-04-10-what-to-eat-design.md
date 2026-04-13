# What to Eat? — Design Spec

## Overview

A Flutter mobile app (iOS + Android) that helps you decide where to eat. Spin a roulette wheel to randomly pick a cuisine, choose a dish type, and get nearby restaurant recommendations ranked by rating.

**Target user:** Solo personal use
**Platform:** Flutter (cross-platform)
**Budget constraint:** Restaurants under $50/person
**API:** Google Places API (using existing Google Maps API key with Places enabled)

---

## User Flow

1. **Spin the Wheel** → Tap to spin a colorful roulette wheel with 5 cuisine segments
2. **Pick a Dish Type** → Select from 20 preset dishes for that cuisine, or type a custom one
3. **Browse Results** → View nearby restaurants ranked by rating in List or Map view
4. **Navigate back** at any step (← Spin again / ← Change dish)

No bottom nav bar. Simple linear back/forward flow between steps.

---

## Screens

### Screen 1: Spin the Wheel (Landing Page)

- App title "What to Eat?" centered at top
- Large roulette wheel with 5 equal color-coded segments, each showing only a country flag:
  - 🇰🇷 Korean (red #FF6B6B)
  - 🇨🇳 Chinese (orange #FFA94D)
  - 🇻🇳 Vietnamese (green #69DB7C)
  - 🇯🇵 Japanese (blue #74C0FC)
  - 🇹🇭 Thai (purple #DA77F2)
- White center circle with "SPIN" text
- Dark triangle pointer at top of wheel
- "TAP TO SPIN" gradient button below wheel
- Cuisine name chips below for reference (flag + name, color-coded)

#### Spin Animation
- **Idle:** Wheel is static
- **On tap:** Wheel spins fast (multiple full rotations), then decelerates with an easing curve (simulating real roulette physics)
- **Landing:** Slows to stop with pointer on a random segment. Winning segment pulses/glows
- **Result reveal:** Bounce animation, cuisine name appears, "Let's go!" button navigates to dish selection
- **Implementation:** `flutter_fortune_wheel` package handles spin animation, pointer, random selection

### Screen 2: Pick a Dish Type

- Back link: "← Spin again" (returns to wheel)
- Shows the cuisine result: "You spun... 🇰🇷 Korean"
- Prompt: "What sounds good?"
- 2x2 grid of dish cards (emoji + name), scrollable
- Dashed "Type your own" card at end
- Search bar at bottom: "Search a dish type..."
- Tapping a card or submitting search navigates to results

### Screen 3: Results — List View

- Back link: "← Change dish" (returns to dish selection)
- Title: dish type name (e.g., "Korean BBQ")
- Subtitle: "📍 Near you · Under $50/person"
- Segmented toggle: List (active) | Map
- Restaurant cards ranked by rating, each showing:
  - Food thumbnail/emoji
  - Restaurant name
  - Rank badge (#1, #2, #3) with color coding
  - Star rating + review count
  - Distance + price level ($ / $$)

### Screen 4: Results — Map View

- Same header and toggle as List View, with Map active
- Google Map showing:
  - Colored numbered pins for each restaurant (matching rank badge colors)
  - Blue dot for user's current location
- Bottom sheet card peeking up showing the selected/top restaurant details
- Tapping a pin shows that restaurant's info in the bottom sheet

---

## Design System

- **Theme:** Light, warm, clean
- **Background:** #FAF7F5 (soft cream)
- **Cards:** White (#FFFFFF) with 16px border-radius, subtle box-shadow
- **Text:** #2D2D2D primary, #999 secondary
- **Accent:** #FF6B6B (primary action color)
- **Star color:** #F59E0B
- **Font:** System default (SF Pro on iOS, Roboto on Android)
- **Corners:** 12-16px radius throughout
- **Shadows:** Subtle (0 2px 12px rgba(0,0,0,0.04))

---

## Cuisine → Dish Mapping (20 per cuisine)

### Korean
1. Korean BBQ (KBBQ) — Tabletop grilled marinated meats
2. Bibimbap — Rice bowl with vegetables, egg
3. Bulgogi — Sweet marinated grilled beef
4. Japchae — Stir-fried glass noodles, vegetables
5. Tteokbokki — Spicy chewy rice cakes
6. Sundubu Jjigae — Soft tofu spicy stew
7. Doenjang Jjigae — Fermented soybean paste stew
8. Kimchi Jjigae — Spicy kimchi pork stew
9. Galbi — Grilled marinated short ribs
10. Samgyeopsal — Grilled thick-cut pork belly
11. Dakgalbi — Spicy stir-fried chicken
12. Haemul Pajeon — Seafood green onion pancake
13. Bossam — Boiled pork with lettuce wraps
14. Jajangmyeon — Noodles in black bean sauce
15. Naengmyeon — Cold buckwheat noodle soup
16. Gamjatang — Spicy pork spine stew
17. Soondubu — Silken tofu hot pot
18. Korean Fried Chicken — Double-fried crispy glazed chicken
19. Gimbap — Korean seaweed rice rolls
20. Kongnamul Bap — Soybean sprout rice bowl

### Chinese
1. General Tso's Chicken — Sweet crispy fried chicken
2. Kung Pao Chicken — Spicy peanut stir-fried chicken
3. Lo Mein — Soft stir-fried egg noodles
4. Fried Rice — Wok-tossed rice, eggs, vegetables
5. Dim Sum — Assorted small steamed dumplings
6. Peking Duck — Lacquered crispy roasted duck
7. Mapo Tofu — Spicy silken tofu, ground pork
8. Orange Chicken — Sweet citrus glazed fried chicken
9. Beef with Broccoli — Stir-fried beef, oyster sauce
10. Mongolian Beef — Savory sweet sliced flank steak
11. Hot and Sour Soup — Tangy spicy broth, tofu
12. Egg Drop Soup — Silky chicken broth, egg ribbons
13. Spring Rolls — Crispy fried vegetable rolls
14. Egg Foo Young — Chinese-style egg omelette
15. Sesame Chicken — Glazed chicken, sesame seeds
16. Dan Dan Noodles — Spicy Sichuan noodles, pork
17. Soup Dumplings (Xiao Long Bao) — Steamed dumplings with broth
18. Scallion Pancake — Flaky fried green onion flatbread
19. Chow Mein — Crispy stir-fried noodles
20. Char Siu (BBQ Pork) — Sweet roasted Cantonese pork

### Vietnamese
1. Pho — Slow-simmered beef noodle soup
2. Banh Mi — Crusty baguette Vietnamese sandwich
3. Bun Bo Hue — Spicy lemongrass beef noodles
4. Com Tam — Broken rice with grilled pork
5. Goi Cuon (Fresh Spring Rolls) — Rice paper shrimp herb rolls
6. Bun Rieu — Crab tomato vermicelli soup
7. Banh Xeo — Sizzling crispy Vietnamese crepe
8. Bun Thit Nuong — Vermicelli grilled pork bowl
9. Ca Phe Sua Da — Vietnamese iced condensed milk coffee
10. Bo Luc Lac — Shaking beef cubes, watercress
11. Chao (Rice Porridge) — Slow-cooked savory rice congee
12. Mi Quang — Turmeric-stained noodles, pork shrimp
13. Cha Gio (Fried Spring Rolls) — Crispy pork vermicelli rolls
14. Hu Tieu — Clear pork seafood noodle soup
15. Banh Cuon — Steamed rice rolls with pork
16. Suon Nuong — Grilled lemongrass pork chop
17. Lau (Hot Pot) — Vietnamese tableside broth pot
18. Bun Mam — Fermented fish noodle soup
19. Banh Bao — Steamed pork-filled buns
20. Banh Canh — Thick tapioca udon-style soup

### Japanese
1. Sushi / Sashimi — Raw fish rice or sliced
2. Ramen — Rich broth wheat noodle soup
3. Tempura — Light battered deep-fried shrimp/vegetables
4. Tonkatsu — Breaded deep-fried pork cutlet
5. Miso Soup — Fermented soybean broth, tofu
6. Udon — Thick wheat noodles in broth
7. Soba — Buckwheat noodles, cold or hot
8. Gyoza — Pan-fried pork dumplings
9. Edamame — Salted steamed soybean pods
10. Teriyaki (Chicken/Salmon) — Sweet glazed grilled protein
11. Yakitori — Skewered charcoal-grilled chicken
12. Donburi (Katsu Don / Oyako Don) — Protein over rice bowl
13. Takoyaki — Grilled octopus batter balls
14. Okonomiyaki — Savory Japanese pancake, cabbage
15. Karaage — Japanese crispy fried chicken
16. Chirashi — Scattered sashimi over sushi rice
17. Onigiri — Triangular seasoned rice balls
18. Shabu-Shabu — Swirled thin-sliced hot pot
19. Ebi Fry — Panko-breaded fried shrimp
20. Matcha Desserts — Green tea ice cream, cake

### Thai
1. Pad Thai — Stir-fried rice noodles, tamarind
2. Tom Yum Soup — Spicy lemongrass shrimp soup
3. Green Curry — Coconut milk herb chicken curry
4. Red Curry — Spicy coconut red chili curry
5. Massaman Curry — Mild peanut potato beef curry
6. Pad See Ew — Wide rice noodles, egg, broccoli
7. Thai Fried Rice (Khao Pad) — Jasmine rice wok-tossed protein
8. Tom Kha Gai — Coconut galangal chicken soup
9. Panang Curry — Rich thick peanut-lime curry
10. Larb (Laab) — Minced meat lime herb salad
11. Papaya Salad (Som Tum) — Shredded green papaya, chili
12. Mango Sticky Rice — Sweet coconut rice, fresh mango
13. Pad Kra Pao — Holy basil stir-fry, fried egg
14. Thai Spring Rolls — Crispy vegetable filled rolls
15. Satay — Grilled peanut sauce skewers
16. Drunken Noodles (Pad Kee Mao) — Spicy wide noodles, basil
17. Khao Soi — Northern Thai coconut curry noodles
18. Crying Tiger — Grilled beef, spicy dipping sauce
19. Thai Basil Fried Rice — Aromatic basil wok fried rice
20. Tod Man Pla — Thai fish cakes, cucumber relish

---

## Technical Architecture

### Approach: Client-Only (No Backend)

Everything runs on the phone. Flutter app calls Google Places API directly. Cuisine/dish data is hardcoded. No server, no accounts, no database.

### Flutter Project Structure

```
what_to_eat/
├── lib/
│   ├── main.dart                    # App entry, theme, routing
│   ├── models/
│   │   ├── cuisine.dart             # Cuisine enum, colors, flags, dish lists
│   │   └── restaurant.dart          # Restaurant model (from API response)
│   ├── screens/
│   │   ├── spin_wheel_screen.dart   # Landing page with wheel
│   │   ├── dish_selection_screen.dart # Dish grid + search
│   │   └── results_screen.dart      # List + Map toggle view
│   ├── widgets/
│   │   ├── spin_wheel.dart          # Wheel widget wrapping flutter_fortune_wheel
│   │   ├── dish_card.dart           # Single dish option card
│   │   └── restaurant_card.dart     # Restaurant result card
│   └── services/
│       ├── location_service.dart    # GPS via geolocator
│       └── places_service.dart      # Google Places API calls
├── pubspec.yaml
└── android/ios/                     # Platform configs + API key setup
```

### Key Flutter Packages

| Package | Purpose |
|---------|---------|
| `flutter_fortune_wheel` | Spin wheel widget with built-in animation |
| `geolocator` | GPS location detection |
| `google_maps_flutter` | Google Maps widget for map view |
| `http` | HTTP calls to Google Places API |

### Google Places API Integration

- **Endpoint:** Places API (New) — Text Search
- **Query:** `"{dishType} restaurant"` near user's `lat,lng`
- **Filters:**
  - `priceLevels`: `[PRICE_LEVEL_INEXPENSIVE, PRICE_LEVEL_MODERATE]` (~under $50/person)
  - `locationBias`: circle around user's GPS coordinates
- **Sort:** By rating descending
- **Response fields used:** name, rating, userRatingCount, formattedAddress, location (lat/lng), priceLevel, photos
- **API key:** User's existing Google Maps API key (needs Places API enabled in Google Cloud Console)

### Data Flow

```
[Spin Wheel] → random cuisine
    ↓
[Dish Selection] → cuisine + dishType
    ↓
[Location Service] → get GPS lat/lng
    ↓
[Places Service] → Text Search("{dishType} restaurant", lat/lng, price filter)
    ↓
[Results Screen] → sorted by rating, displayed as list or map pins
```

### Navigation

Simple `Navigator.push` / `Navigator.pop` stack:

```
SpinWheelScreen → DishSelectionScreen(cuisine) → ResultsScreen(cuisine, dishType)
                  ← pop (Spin again)              ← pop (Change dish)
```

---

## Error Handling

- **No GPS permission:** Show dialog asking user to enable location services
- **No internet:** Show retry screen with message
- **No results:** "No restaurants found nearby. Try a different dish type."
- **API error:** Generic error with retry button

---

## Out of Scope (v1)

- User accounts / login
- Favorites / history
- Backend server
- Push notifications
- Multiple user group voting
- Custom cuisine additions (hardcoded 5 cuisines for now)
