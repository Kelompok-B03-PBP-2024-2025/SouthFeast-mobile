import 'package:flutter/material.dart';
import 'package:southfeast_mobile/restaurant/models/restaurant/restaurant.dart';
import 'package:southfeast_mobile/dashboard/screens/restaurant_detail_screen.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantElement restaurant;
  final double imageSize;
  final double horizontalPadding;
  final double fontSize;
  final VoidCallback onRefresh;

  const RestaurantCard({
    required this.restaurant,
    required this.imageSize,
    required this.horizontalPadding,
    required this.fontSize,
    required this.onRefresh,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RestaurantDetailAdmin(
                  restaurant: restaurant,
                  isStaff: true, // Adjust based on your actual user role
                  isAuthenticated: true, // Adjust based on authentication status
                  onRefresh: onRefresh,
                ),
              ),
            );
            // Call refresh regardless of result to ensure latest data
            onRefresh();
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.all(horizontalPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: imageSize,
                    height: imageSize,
                    child: Image.network(
                      restaurant.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: imageSize * 0.4,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: horizontalPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, 
                            size: fontSize, 
                            color: Colors.grey.shade700
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              restaurant.kecamatan,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: fontSize - 2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp${restaurant.minPrice} - ${restaurant.maxPrice}',
                        style: TextStyle(
                          fontSize: fontSize - 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
