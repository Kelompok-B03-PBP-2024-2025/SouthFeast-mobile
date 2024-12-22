import 'package:flutter/material.dart';
import 'package:southfeast_mobile/restaurant/models/restaurant/restaurant.dart';
import 'package:southfeast_mobile/dashboard/widgets/restaurant_card.dart';

class RestaurantList extends StatelessWidget {
  final List<RestaurantElement> restaurants;
  final ScrollController scrollController;
  final bool isLoading;
  final VoidCallback onRefresh;

  const RestaurantList({
    required this.restaurants,
    required this.scrollController,
    required this.isLoading,
    required this.onRefresh,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading && restaurants.isEmpty) {
      return const Center(
        child: Text(
          'Loading...',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    if (restaurants.isEmpty) {
      return const Center(
        child: Text(
          'No restaurants found',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth < 360 ? 80.0 : screenWidth < 600 ? 100.0 : 120.0;
    final horizontalPadding = screenWidth < 360 ? 8.0 : 12.0;
    final fontSize = screenWidth < 360 ? 14.0 : 16.0;

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(horizontalPadding),
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
              return Padding(
                padding: EdgeInsets.symmetric(
                  vertical: horizontalPadding * 0.5,
                  horizontal: horizontalPadding,
                ),
                child: RestaurantCard(
                  restaurant: restaurant,
                  imageSize: imageSize,
                  horizontalPadding: horizontalPadding,
                  fontSize: fontSize,
                  onRefresh: onRefresh, // Pass callback here
                ),
              );
            },
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }
}