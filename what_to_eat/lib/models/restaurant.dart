class Restaurant {
  final String name;
  final double rating;
  final int reviewCount;
  final String address;
  final double latitude;
  final double longitude;
  final int priceLevel;
  // Yelp-specific fields
  final String? imageUrl;
  final String? phone;
  final double? distanceMeters;
  final List<String> categories;
  final String? yelpUrl;
  final String? yelpId;
  // Google ratings (fetched separately)
  final double? googleRating;
  final int? googleReviewCount;

  const Restaurant({
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.priceLevel,
    this.imageUrl,
    this.phone,
    this.distanceMeters,
    this.categories = const [],
    this.yelpUrl,
    this.yelpId,
    this.googleRating,
    this.googleReviewCount,
  });

  /// Returns a new Restaurant with Google rating data merged in.
  Restaurant withGoogleRating({
    required double? googleRating,
    required int? googleReviewCount,
  }) {
    return Restaurant(
      name: name,
      rating: rating,
      reviewCount: reviewCount,
      address: address,
      latitude: latitude,
      longitude: longitude,
      priceLevel: priceLevel,
      imageUrl: imageUrl,
      phone: phone,
      distanceMeters: distanceMeters,
      categories: categories,
      yelpUrl: yelpUrl,
      yelpId: yelpId,
      googleRating: googleRating,
      googleReviewCount: googleReviewCount,
    );
  }

  /// Weighted average of Yelp and Google ratings by review count.
  /// Falls back to whichever source has data.
  double get combinedRating {
    final hasYelp = rating > 0 && reviewCount > 0;
    final hasGoogle =
        googleRating != null && googleRating! > 0 && (googleReviewCount ?? 0) > 0;

    if (hasYelp && hasGoogle) {
      final totalCount = reviewCount + googleReviewCount!;
      return (rating * reviewCount + googleRating! * googleReviewCount!) /
          totalCount;
    }
    if (hasGoogle) return googleRating!;
    return rating;
  }

  /// Sum of Yelp and Google review counts.
  int get combinedReviewCount {
    return reviewCount + (googleReviewCount ?? 0);
  }

  /// Display string like "4.3 (Yelp 4.5 · Google 4.1)".
  String get totalReviewDisplay {
    final combined = combinedRating.toStringAsFixed(1);
    final hasYelp = rating > 0;
    final hasGoogle = googleRating != null && googleRating! > 0;

    if (hasYelp && hasGoogle) {
      final yelpStr = rating.toStringAsFixed(1);
      final googleStr = googleRating!.toStringAsFixed(1);
      return '$combined (Yelp $yelpStr · Google $googleStr)';
    }
    if (hasGoogle) {
      return '${googleRating!.toStringAsFixed(1)} (Google)';
    }
    return '$combined (Yelp)';
  }

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

  factory Restaurant.fromYelpJson(Map<String, dynamic> json) {
    final coords = json['coordinates'] as Map<String, dynamic>?;
    final location = json['location'] as Map<String, dynamic>?;
    final categoriesList = json['categories'] as List<dynamic>? ?? [];
    final categories = categoriesList
        .map((c) => (c as Map<String, dynamic>)['title'] as String? ?? '')
        .where((t) => t.isNotEmpty)
        .toList();

    // Yelp price: '$', '$$', '$$$', '$$$$'
    final priceStr = json['price'] as String? ?? '';
    final priceLevel = priceStr.length; // length of '$' chars

    final address1 = location?['address1'] as String? ?? '';
    final city = location?['city'] as String? ?? '';
    final address = city.isNotEmpty ? '$address1, $city' : address1;

    return Restaurant(
      name: json['name'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      address: address,
      latitude: (coords?['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (coords?['longitude'] as num?)?.toDouble() ?? 0.0,
      priceLevel: priceLevel,
      imageUrl: json['image_url'] as String?,
      phone: json['display_phone'] as String?,
      distanceMeters: (json['distance'] as num?)?.toDouble(),
      categories: categories,
      yelpUrl: json['url'] as String?,
      yelpId: json['id'] as String?,
    );
  }

  String get priceLevelDisplay {
    if (priceLevel <= 0) return '';
    return '\$' * priceLevel;
  }

  String get distanceDisplay {
    if (distanceMeters == null) return '';
    final miles = distanceMeters! / 1609.34;
    if (miles < 0.1) return '< 0.1 mi';
    return '${miles.toStringAsFixed(1)} mi';
  }
}
