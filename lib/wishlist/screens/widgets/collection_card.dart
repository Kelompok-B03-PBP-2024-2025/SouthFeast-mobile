// import 'package:flutter/material.dart';

// class CollectionCard extends StatelessWidget {
//   final Map<String, dynamic> item;
//   final VoidCallback onRemove;
//   final Function(int) onMove;

//   const CollectionCard({
//     super.key,
//     required this.item,
//     required this.onRemove,
//     required this.onMove,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final menuItem = item['menu_item'];
//     final imageUrl = menuItem['image'] ?? '';
//     final name = menuItem['name'] ?? 'No Name';
//     final price = menuItem['price'] ?? 'Unknown Price';

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Item Details'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (imageUrl.isNotEmpty)
//               Center(
//                 child: Image.network(
//                   imageUrl,
//                   width: 200,
//                   height: 200,
//                   errorBuilder: (context, error, stackTrace) {
//                     return const Icon(Icons.error, size: 100);
//                   },
//                 ),
//               ),
//             const SizedBox(height: 16),
//             Text(
//               name,
//               style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Price: $price',
//               style: const TextStyle(fontSize: 18),
//             ),
//             const Spacer(),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.delete),
//                   label: const Text('Remove'),
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                   onPressed: onRemove,
//                 ),
//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.drive_file_move),
//                   label: const Text('Move'),
//                   onPressed: () => showMoveDialog(context),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void showMoveDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Move Item'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: const [
//             Text('Choose a collection to move this item to:'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               // Assume targetCollectionId is fetched from a dropdown or input
//               final targetCollectionId = 1; // Replace with actual value
//               Navigator.pop(context);
//               onMove(targetCollectionId);
//             },
//             child: const Text('Move'),
//           ),
//         ],
//       ),
//     );
//   }
// }
