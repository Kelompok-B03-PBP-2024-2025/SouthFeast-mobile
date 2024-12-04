import 'package:flutter/material.dart';

class RestaurantGrid extends StatelessWidget {
  final List<String> dummyRestaurants = [
    'Restaurant 1',
    'Restaurant 2',
    'Restaurant 3',
    'Restaurant 4',
    'Restaurant 5',
    'Restaurant 6',
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: dummyRestaurants.length,
      itemBuilder: (ctx, i) => Card(
        child: Center(
          child: Text(dummyRestaurants[i]),
        ),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}