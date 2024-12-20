import 'package:flutter/material.dart';
import 'package:southfeast_mobile/dashboard/models/product/result.dart';
import 'package:southfeast_mobile/dashboard/screens/edit_makanan.dart'; // Add this line
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:southfeast_mobile/dashboard/screens/detail_makanan.dart'; // Add this line
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:southfeast_mobile/dashboard/screens/restaurant_detail_screen.dart';  // Add this import
import 'package:southfeast_mobile/restaurant/models/restaurant/restaurant.dart';
import 'package:southfeast_mobile/restaurant/services/restaurant_service.dart';
class ProductGrid extends StatelessWidget {
  final List<Result> products;
  final ScrollController scrollController;
  final bool isLoading;
  final Function()? onUpdate; // Add this line

  const ProductGrid({
    Key? key,
    required this.products,
    required this.scrollController,
    required this.isLoading,
    this.onUpdate, // Add this line
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final request = context.watch<CookieRequest>();
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculate responsive dimensions
    final imageSize = screenWidth < 360
        ? 80.0
        : screenWidth < 600
            ? 100.0
            : 120.0;
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
            itemCount: products.length,
            itemBuilder: (context, index) {
              Result product = products[index];
              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(
                  vertical: horizontalPadding * 0.5,
                  horizontal: horizontalPadding,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Slidable(
                    key: ValueKey(product.id),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      extentRatio: 0.5,
                      children: [
                        CustomSlidableAction(
                          flex: 1,
                          onPressed: (context) async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditMakananForm(
                                  makanan: {
                                    'id': product.id,
                                    'name': product.name,
                                    'description': product.description,
                                    'price': product.price,
                                    'image': product.image,
                                    'category': product.category,
                                    'restaurant_name': product.restaurantName,
                                    'kecamatan': product.kecamatan,
                                    'location': product.location,
                                  },
                                ),
                              ),
                            );
                            if (result != null && onUpdate != null) {
                              onUpdate!();
                            }
                          },
                          backgroundColor: Colors.blue.shade400,
                          foregroundColor: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.edit),
                              SizedBox(height: 4),
                              Text('Edit', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        CustomSlidableAction(
                          flex: 1,
                          onPressed: (BuildContext slideContext) async {
                            try {
                              final bool shouldDelete = await showDialog<bool>(
                                context: slideContext,
                                barrierDismissible: false,
                                builder: (BuildContext dialogContext) => AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: const Text('Are you sure you want to delete this item?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () => Navigator.of(dialogContext).pop(false),
                                    ),
                                    TextButton(
                                      child: const Text('Delete'),
                                      style: ButtonStyle(
                                        foregroundColor: WidgetStateProperty.all<Color>(Colors.red),
                                      ),
                                      onPressed: () => Navigator.of(dialogContext).pop(true),
                                    ),
                                  ],
                                ),
                              ) ?? false;

                              if (shouldDelete) {
                                final request = context.read<CookieRequest>();
                                final deleteUrl = 'https://southfeast-production.up.railway.app/delete-makanan-flutter/${product.id}/';
                                final response = await request.get(deleteUrl);

                                if (response['status'] == 'success') {
                                  if (slideContext.mounted) {
                                    ScaffoldMessenger.of(slideContext).showSnackBar(
                                      const SnackBar(content: Text('Item deleted successfully')),
                                    );
                                  }
                                  
                                  if (onUpdate != null) {
                                    onUpdate!();
                                  }
                                } else {
                                  throw Exception(response['message'] ?? 'Unknown error');
                                }
                              }
                            } catch (e) {
                              if (slideContext.mounted) {
                                ScaffoldMessenger.of(slideContext).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete),
                              SizedBox(height: 4),
                              Text('Delete', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () async {
                        final refreshedData = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailMakanan(
                              result: product,
                              onUpdate: onUpdate, isStaff: true, isAuthenticated: true,
                            ),
                          ),
                        );

                        if (refreshedData == true && onUpdate != null) {
                          onUpdate!();
                        }
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
                            // Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: imageSize,
                                height: imageSize,
                                child: product.image != null
                                    ? Image.network(
                                        product.image!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey.shade200,
                                            child: Icon(
                                              Icons.broken_image_outlined,
                                              size: imageSize * 0.4,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        color: Colors.grey.shade200,
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: imageSize * 0.4,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(width: horizontalPadding),
                            // Product Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name ?? 'Unnamed Product',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: fontSize,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.category ?? 'No Category',
                                    style: TextStyle(
                                      fontSize: fontSize - 2,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp${product.price ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: fontSize - 2,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Restaurant and Location info with responsive text
                                  Row(
                                    children: [
                                      Icon(Icons.restaurant,
                                          size: fontSize,
                                          color: Colors.blue.shade700),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            try {
                                              final request = context.read<CookieRequest>();
                                              // Fetch full restaurant details using RestaurantService
                                              final restaurantDetail = await RestaurantService.fetchRestaurantDetail(
                                                request,
                                                product.restaurantId ?? -1,
                                              );
                                              if (context.mounted) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => RestaurantDetailScreen(
                                                      restaurant: restaurantDetail,
                                                      isStaff: true,
                                                      isAuthenticated: true,
                                                    ),
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Error loading restaurant: $e')),
                                                );
                                              }
                                            }
                                          },
                                          child: Text(
                                            product.restaurantName ?? 'N/A',
                                            style: TextStyle(
                                              color: Colors.blue.shade700,
                                              fontSize: fontSize - 2,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: screenWidth < 360 ? 2 : 4),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          size: fontSize,
                                          color: Colors.grey.shade700),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          product.kecamatan ?? 'N/A',
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: fontSize - 2,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
