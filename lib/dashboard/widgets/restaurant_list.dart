import 'package:flutter/material.dart';
import 'package:southfeast_mobile/restaurant/models/restaurant/restaurant_model.dart';
import 'package:southfeast_mobile/dashboard/widgets/restaurant_card.dart';

class RestaurantList extends StatelessWidget {
  final List<Restaurant> restaurants;
  final ScrollController scrollController;
  final bool isLoading;

  const RestaurantList({
    required this.restaurants,
    required this.scrollController,
    required this.isLoading,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(
        'RestaurantList build - restaurants length: ${restaurants.length}'); // Debug print

    if (restaurants.isEmpty) {
      print('No restaurants in the list'); // Debug print
      return const Center(
        child: Text('No restaurants found'),
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
                ),
              );
            },
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}