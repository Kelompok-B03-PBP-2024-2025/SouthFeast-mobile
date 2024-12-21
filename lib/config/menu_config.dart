
import 'package:flutter/material.dart';
import 'package:southfeast_mobile/screens/homepage.dart';
import 'package:southfeast_mobile/dashboard/screens/dashboard.dart';
import 'package:southfeast_mobile/review/screens/review.dart';
import 'package:southfeast_mobile/forum/screens/forum.dart';
import 'package:southfeast_mobile/product/screens/product.dart';
import 'package:southfeast_mobile/restaurant/screens/restaurant.dart';
import 'package:southfeast_mobile/wishlist/screens/wishlist.dart';

class MenuConfig {
  static List<Map<String, dynamic>> getMenuItems({
    required bool isStaff,
    required bool isAuthenticated,
    String? username,
  }) {
    if (isStaff) {
      return [
        {
          "title": "Home",
          "icon": Icons.home,
          "screen": HomePage(),
          "requiresAuth": false,
        },
        {
          "title": "Dashboard",
          "icon": Icons.dashboard,
          "screen": const DashboardPage(),
          "requiresAuth": true,
        },
        {
          "title": "Review",
          "icon": Icons.rate_review,
          "screen":  ReviewPage(),
          "requiresAuth": false,
        },
        {
          "title": "Forum",
          "icon": Icons.forum,
          "screen": const ForumPage(),
          "requiresAuth": false,
        },
      ];
    } else {
      return [
        {
          "title": "Home",
          "icon": Icons.home,
          "screen": HomePage(),
          "requiresAuth": false,
        },
        {
          "title": "Catalog",
          "icon": Icons.shopping_cart,
          "screen": const ProductPage(),
          "requiresAuth": false,
        },
        {
          "title": "Restaurant",
          "icon": Icons.restaurant,
          "screen": const RestaurantPage(),
          "requiresAuth": false,
        },
        {
          "title": "Wishlist",
          "icon": Icons.favorite,
          "screen": const WishlistPage(),
          "requiresAuth": true,
        },
        {
          "title": "Culinary Insights",
          "icon": Icons.forum,
          "screen": const ForumPage(),
          "requiresAuth": false,
        },
        {
          "title": "Review",
          "icon": Icons.rate_review,
          "screen":  ReviewPage(),
          "requiresAuth": false,
        },
      ];
    }
  }
}