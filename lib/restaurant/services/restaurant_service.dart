import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:southfeast_mobile/restaurant/models/restaurant/restaurant.dart';
import 'dart:convert';

class RestaurantService {
  static Future<Restaurant> fetchRestaurants(
    CookieRequest request, {
    String? search,
    String? kecamatan,
    int page = 1,
  }) async {
    try {
      final response = await request.get(
          'http://127.0.0.1:8000/restaurant/show-json-restaurant/?page=$page'
          '${kecamatan != null && kecamatan != 'all' ? '&kecamatan=$kecamatan' : ''}'
          '${search != null && search.isNotEmpty ? '&search=$search' : ''}');

      if (response != null) {
        // Cast the response to Map<String, dynamic>
        if (response is Map) {
          Map<String, dynamic> castedResponse = Map<String, dynamic>.from(response);
          return Restaurant.fromJson(castedResponse);
        }
        // If it's a string, parse it
        else if (response is String) {
          return Restaurant.fromJson(json.decode(response));
        }
      }
      throw Exception('Invalid response format');
    } catch (e, stackTrace) {
      print('Error details: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to fetch restaurants: $e');
    }
  }

  static Future<RestaurantElement> fetchRestaurantDetail(
    CookieRequest request,
    int restaurantId,
  ) async {
    try {
      final response = await request.get(
        'http://127.0.0.1:8000/restaurant/get-restaurant/$restaurantId/',
      );

      if (response != null) {
        if (response is Map) {
          Map<String, dynamic> castedResponse = Map<String, dynamic>.from(response);
          return RestaurantElement.fromJson(castedResponse);
        } else if (response is String) {
          return RestaurantElement.fromJson(json.decode(response));
        }
      }
      throw Exception('Invalid response format');
    } catch (e) {
      print('Error details: $e');
      throw Exception('Failed to fetch restaurant detail: $e');
    }
  }
}
