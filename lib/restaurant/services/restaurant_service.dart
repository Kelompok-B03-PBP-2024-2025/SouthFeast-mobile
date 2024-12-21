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
          'https://southfeast-production.up.railway.app/restaurant/show-json-restaurant/?page=$page'
          '${kecamatan != null && kecamatan != 'all' ? '&kecamatan=$kecamatan' : ''}'
          '${search != null && search.isNotEmpty ? '&search=$search' : ''}');

      if (response != null) {
        // Cast the response to Map<String, dynamic>
        if (response is Map) {
          Map<String, dynamic> castedResponse = Map<String, dynamic>.from(response);
          return Restaurant.fromJson(castedResponse);
        } else if (response is String) {
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
        'https://southfeast-production.up.railway.app/restaurant/get-restaurant/$restaurantId/',
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

  static Future<RestaurantElement> fetchRestaurantByName(
    CookieRequest request,
    String restaurantName,
  ) async {
    int page = 1;

    try {
      print('Searching for restaurant: $restaurantName');

      while (true) {
        // Fetch the restaurant data from the API for the current page
        final response = await request.get(
          'https://southfeast-production.up.railway.app/restaurant/show-json-restaurant/?page=$page',
        );

        // Check if response is not null
        if (response != null) {
          // Cast response to a Map
          final castedResponse = Map<String, dynamic>.from(response);

          // Access the list of restaurants
          final restaurantList = castedResponse['restaurants'] as List<dynamic>?;

          // If there are no restaurants, break the loop
          if (restaurantList == null || restaurantList.isEmpty) {
            print('No more restaurants found on page $page');
            break;
          }

          for (final restaurant in restaurantList) {
            // Convert each restaurant to a RestaurantElement
            final element = RestaurantElement.fromJson(
              Map<String, dynamic>.from(restaurant as Map),
            );

            // Check if the restaurant name matches
            if (element.name.toLowerCase() == restaurantName.toLowerCase()) {
              return element; // Return the matching restaurant
            }
          }

          // Increment the page number to fetch the next page
          page++;
        } else {
          print('No response received on page $page');
          break; // Stop if the response is null
        }
      }

      // Throw an exception if the restaurant is not found
      throw Exception('Restaurant with name "$restaurantName" not found');
    } catch (e, stackTrace) {
      print('Error details: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to fetch restaurant by name: $e');
    }
  }


}