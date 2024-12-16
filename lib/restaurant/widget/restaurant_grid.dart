// // restaurant_grid.dart

// import 'package:flutter/material.dart';
// import '../models/restaurant/restaurant_models.dart';

// class RestaurantGrid extends StatelessWidget {
//   final List<Restaurant> restaurants;

//   const RestaurantGrid({
//     Key? key,
//     required this.restaurants,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       padding: const EdgeInsets.all(16),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 0.8,
//         crossAxisSpacing: 16,
//         mainAxisSpacing: 16,
//       ),
//       itemCount: restaurants.length,
//       itemBuilder: (context, index) {
//         final restaurant = restaurants[index];
//         return GestureDetector(
//           onTap: () {
//             Navigator.pushNamed(
//               context,
//               '/restaurant-detail',
//               arguments: restaurant,
//             );
//           },
//           child: Card(
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   flex: 3,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: const BorderRadius.vertical(
//                         top: Radius.circular(12),
//                       ),                    
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   flex: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           restaurant.name,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           restaurant.location,
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey,
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }