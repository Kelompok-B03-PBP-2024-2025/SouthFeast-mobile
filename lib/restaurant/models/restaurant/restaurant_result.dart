// TODO Implement this library.
// restaurant_result.dart
import 'package:southfeast_mobile/restaurant/models/restaurant/menu_item.dart';

class RestaurantResult {
  final String? restoName;
  final String? city;
  final String? kecamatan;
  final String? location;
  final List<MenuItem>? menu;

  RestaurantResult({
    this.restoName,
    this.city,
    this.kecamatan,
    this.location,
    this.menu,
  });

  factory RestaurantResult.fromMap(Map<String, dynamic> data) => RestaurantResult(
        restoName: data['resto_name'] as String?,
        city: data['city'] as String?,
        kecamatan: data['kecamatan'] as String?,
        location: data['location'] as String?,
        menu: (data['menu'] as List<dynamic>?)
            ?.map((e) => MenuItem.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'resto_name': restoName,
        'city': city,
        'kecamatan': kecamatan,
        'location': location,
        'menu': menu?.map((e) => e.toMap()).toList(),
      };
}
