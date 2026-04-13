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
  korean,
  chinese,
  vietnamese,
  japanese,
  thai;

  String get displayName {
    switch (this) {
      case Cuisine.korean:
        return 'Korean';
      case Cuisine.chinese:
        return 'Chinese';
      case Cuisine.vietnamese:
        return 'Vietnamese';
      case Cuisine.japanese:
        return 'Japanese';
      case Cuisine.thai:
        return 'Thai';
    }
  }

  String get flag {
    switch (this) {
      case Cuisine.korean:
        return '🇰🇷';
      case Cuisine.chinese:
        return '🇨🇳';
      case Cuisine.vietnamese:
        return '🇻🇳';
      case Cuisine.japanese:
        return '🇯🇵';
      case Cuisine.thai:
        return '🇹🇭';
    }
  }

  Color get color {
    switch (this) {
      case Cuisine.korean:
        return const Color(0xFFFF6B6B);
      case Cuisine.chinese:
        return const Color(0xFFFFA94D);
      case Cuisine.vietnamese:
        return const Color(0xFF69DB7C);
      case Cuisine.japanese:
        return const Color(0xFF74C0FC);
      case Cuisine.thai:
        return const Color(0xFFDA77F2);
    }
  }

  List<Dish> get dishes {
    switch (this) {
      case Cuisine.korean:
        return const [
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
        ];
      case Cuisine.chinese:
        return const [
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
        ];
      case Cuisine.vietnamese:
        return const [
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
        ];
      case Cuisine.japanese:
        return const [
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
        ];
      case Cuisine.thai:
        return const [
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
          Dish(name: 'Thai Basil Fried Rice', description: 'Basil wok-fried jasmine rice', emoji: '🍚'),
          Dish(name: 'Tod Man Pla', description: 'Thai fish cakes, cucumber relish', emoji: '🐟'),
        ];
    }
  }
}
