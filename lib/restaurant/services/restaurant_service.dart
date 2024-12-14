import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:southfeast_mobile/restaurant/models/restaurant/restaurant_model.dart';

class RestaurantService {
  static Future<List<Restaurant>> fetchRestaurants(
    CookieRequest request, {
    String? search,
    String? kecamatan,
    int page = 1,
  }) async {
    try {
      final response = await request.get(
          // 'http://10.0.2.2:8000/restaurant/show-json-restaurant/?page=$page'
          'https://southfeast-production.up.railway.app/restaurant/show-json-restaurant/?page=$page'
          '${kecamatan != null && kecamatan != 'all' ? '&kecamatan=$kecamatan' : ''}'
          '${search != null && search.isNotEmpty ? '&search=$search' : ''}');

      print('Raw API Response: $response'); // Debug print

      if (response != null) {
        // Parse restaurants directly from the 'restaurants' key
        final List<dynamic> restaurantsJson = response['restaurants'] ?? [];
        return restaurantsJson.map((json) => Restaurant.fromMap(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching restaurants: $e');
      throw Exception('Failed to fetch restaurants');
    }
  }
}
