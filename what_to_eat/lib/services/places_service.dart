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
          'radius': 8000.0,
        },
      },
      'priceLevels': [
        'PRICE_LEVEL_INEXPENSIVE',
        'PRICE_LEVEL_MODERATE',
      ],
      'maxResultCount': 10,
    };
  }

  /// Searches for a specific restaurant by name near the given coordinates
  /// and returns its Google rating and review count.
  /// Returns null for both fields if the place cannot be found.
  Future<({double? rating, int? reviewCount})> getPlaceRating(
    String name,
    double lat,
    double lng,
  ) async {
    final body = {
      'textQuery': name,
      'locationBias': {
        'circle': {
          'center': {'latitude': lat, 'longitude': lng},
          'radius': 300.0,
        },
      },
      'maxResultCount': 1,
    };

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask': 'places.rating,places.userRatingCount',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      return (rating: null, reviewCount: null);
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final places = json['places'] as List<dynamic>?;
    if (places == null || places.isEmpty) {
      return (rating: null, reviewCount: null);
    }

    final place = places.first as Map<String, dynamic>;
    final rating = (place['rating'] as num?)?.toDouble();
    final reviewCount = place['userRatingCount'] as int?;
    return (rating: rating, reviewCount: reviewCount);
  }

  Future<List<String>> getPlacePhotos(
    String query,
    double lat,
    double lng,
  ) async {
    // Step 1: Search for the place to get its place ID and photos
    final body = {
      'textQuery': query,
      'locationBias': {
        'circle': {
          'center': {'latitude': lat, 'longitude': lng},
          'radius': 500.0,
        },
      },
      'maxResultCount': 1,
    };

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask': 'places.photos',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      return [];
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final places = json['places'] as List<dynamic>?;
    if (places == null || places.isEmpty) return [];

    final firstPlace = places.first as Map<String, dynamic>;
    final photos = firstPlace['photos'] as List<dynamic>? ?? [];

    // Step 2: Build photo media URLs from photo name references
    return photos
        .take(10)
        .map((p) {
          final photoName = (p as Map<String, dynamic>)['name'] as String? ?? '';
          if (photoName.isEmpty) return '';
          return 'https://places.googleapis.com/v1/$photoName/media'
              '?maxHeightPx=800&maxWidthPx=800&key=$apiKey';
        })
        .where((url) => url.isNotEmpty)
        .toList();
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
