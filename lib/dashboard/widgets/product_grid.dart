import 'package:flutter/material.dart';
import 'package:southfeast_mobile/dashboard/models/product/result.dart';
import 'package:southfeast_mobile/dashboard/screens/edit_makanan.dart'; // Add this line
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:southfeast_mobile/dashboard/screens/detail_makanan.dart'; // Add this line

class ProductGrid extends StatelessWidget {
  final List<Result> products;
  final ScrollController scrollController;
  final bool isLoading;
  final Function()? onUpdate;  // Add this line

  const ProductGrid({
    Key? key,
    required this.products,
    required this.scrollController,
    required this.isLoading,
    this.onUpdate,  // Add this line
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62, // Further reduced to accommodate buttons
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              Result product = products[index];
              return GestureDetector(
                // In ProductGrid.dart, replace the existing onTap with:
                onTap: () async {  // Ubah onTap menjadi async
                  final refreshedData = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailMakanan(
                        result: product,
                        onUpdate: onUpdate,  // Tambahkan onUpdate
                      ),
                    ),
                  );
                  
                  // Refresh data jika ada perubahan
                  if (refreshedData == true && onUpdate != null) {
                    onUpdate!();
                  }
                },
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: product.image != null
                              ? Image.network(
                                  product.image!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.broken_image_outlined,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                )
                              : const Icon(Icons.image_not_supported),
                        ),
                      ),
                      // Product info
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0), // Reduced horizontal padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min, // Added to minimize vertical space
                            children: [
                              Text(
                                product.name ?? 'Unnamed Product',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13, // Slightly reduced font size
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2), // Reduced spacing
                              Text(
                                'Rp${product.price ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13, // Added consistent font size
                                ),
                              ),
                              const SizedBox(height: 2), // Reduced spacing
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/restaurant-detail',
                                    arguments: product.restaurantName,
                                  );
                                },
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.restaurant,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        product.restaurantName ?? 'N/A',
                                        style: TextStyle(
                                          color: Colors.blue[700],
                                          fontSize: 12,
                                          decoration: TextDecoration.underline,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      product.kecamatan ?? 'N/A',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center, // Changed to center
                                children: [
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () async {
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
                                      // Refresh data ketika edit berhasil
                                      if (result != null && onUpdate != null) {
                                        onUpdate!();
                                      }
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(Icons.edit, size: 18),
                                    ),
                                  ),
                                  const SizedBox(width: 50), // Increased spacing between buttons
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Confirm Delete'),
                                            content: const Text('Are you sure you want to delete this item?'),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text('Cancel'),
                                                style: ButtonStyle(
                                                  foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
                                                ),
                                                onPressed: () => Navigator.of(context).pop(false),
                                              ),
                                              TextButton(
                                                child: const Text('Delete'),
                                                style: ButtonStyle(
                                                  foregroundColor: WidgetStateProperty.all<Color>(Colors.red),
                                                ),
                                                onPressed: () => Navigator.of(context).pop(true),
                                              ),
                                            ],
                                          );
                                        },
                                      ).then((confirm) async {
                                        if (confirm && context.mounted) {
                                          final response = await request.get(
                                            'http://10.0.2.2:8000/dashboard/delete-makanan-flutter/${product.id}/',
                                          );
                                          if (response['status'] == 'success' && onUpdate != null) {
                                            onUpdate!();
                                          }
                                        }
                                      });
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(Icons.delete, size: 18),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2), // Added small bottom padding
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}