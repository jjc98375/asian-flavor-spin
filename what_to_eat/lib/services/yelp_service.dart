import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';
import '../models/restaurant_detail.dart';
import '../models/yelp_review.dart';

class YelpService {
  final String apiKey;

  const YelpService({required this.apiKey});

  static const _baseUrl = 'https://api.yelp.com/v3/businesses/search';
  static const _detailBaseUrl = 'https://api.yelp.com/v3/businesses';

  Future<List<Restaurant>> searchRestaurants({
    required String dishType,
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'term': dishType,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'radius': '8000',
      'limit': '10',
      'sort_by': 'rating',
    });

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw YelpServiceException(
        'Yelp API error: ${response.statusCode} ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return parseResponse(json);
  }

  Future<RestaurantDetail> getBusinessDetails(String yelpId) async {
    final uri = Uri.parse('$_detailBaseUrl/$yelpId');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw YelpServiceException(
        'Yelp API error: ${response.statusCode} ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return RestaurantDetail.fromYelpDetailJson(json);
  }

  Future<List<YelpReview>> getBusinessReviews(String yelpId) async {
    final uri = Uri.parse('$_detailBaseUrl/$yelpId/reviews').replace(
      queryParameters: {'limit': '10', 'sort_by': 'yelp_sort'},
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      return [];
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final reviews = json['reviews'] as List<dynamic>? ?? [];
    return reviews
        .map((r) => YelpReview.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  static List<Restaurant> parseResponse(Map<String, dynamic> json) {
    final businesses = json['businesses'] as List<dynamic>?;
    if (businesses == null) return [];

    return businesses
        .map((b) => Restaurant.fromYelpJson(b as Map<String, dynamic>))
        .toList();
  }
}

class YelpServiceException implements Exception {
  final String message;
  const YelpServiceException(this.message);

  @override
  String toString() => message;
}
