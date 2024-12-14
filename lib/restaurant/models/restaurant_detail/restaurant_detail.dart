import 'menu_item.dart';
import 'restaurant.dart';
import 'stats.dart';

class RestaurantDetail {
  String? status;
  Restaurant? restaurant;
  Stats? stats;
  List<MenuItem>? menuItems;

  RestaurantDetail({
    this.status,
    this.restaurant,
    this.stats,
    this.menuItems,
  });

  factory RestaurantDetail.fromJson(Map<String, dynamic> json) {
    return RestaurantDetail(
      status: json['status'] as String?,
      restaurant: json['restaurant'] == null
          ? null
          : Restaurant.fromJson(json['restaurant'] as Map<String, dynamic>),
      stats: json['stats'] == null
          ? null
          : Stats.fromJson(json['stats'] as Map<String, dynamic>),
      menuItems: (json['menu_items'] as List<dynamic>?)
          ?.map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'restaurant': restaurant?.toJson(),
        'stats': stats?.toJson(),
        'menu_items': menuItems?.map((e) => e.toJson()).toList(),
      };
}
