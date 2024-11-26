// lib/screens/restaurant_page.dart
import 'package:flutter/material.dart';

class RestaurantPage extends StatelessWidget {
  const RestaurantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.restaurant, size: 64),
          SizedBox(height: 16),
          Text('Restaurant Content'),
        ],
      ),
    );
  }
}
