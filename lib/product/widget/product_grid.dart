import 'package:flutter/material.dart';
import 'package:southfeast_mobile/dashboard/models/product/result.dart';
import 'package:southfeast_mobile/product/screens/detail_makanan.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:southfeast_mobile/restaurant/models/restaurant/restaurant.dart';
// import 'package:southfeast_mobile/restaurant/screens/restaurant.dart';
import 'package:southfeast_mobile/restaurant/screens/restaurant_detail.dart';

class ProductGrid extends StatelessWidget {
  final List<Result> products;
  final ScrollController scrollController;
  final bool isLoading;
  final VoidCallback onUpdate;
  final bool isAdmin;
  final Set<int> wishlistedProducts;
  final Function(int) onWishlistToggle;

  const ProductGrid({
    super.key,
    required this.products,
    required this.scrollController,
    required this.isLoading,
    required this.onUpdate,
    required this.isAdmin,
    required this.wishlistedProducts,
    required this.onWishlistToggle,
  });

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
              childAspectRatio: 0.75, // Diubah dari 0.62 untuk card yang lebih proporsional
              crossAxisSpacing: 8, // Dikurangi dari 10
              mainAxisSpacing: 8, // Dikurangi dari 10
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              Result product = products[index];
              bool isInWishlist = wishlistedProducts.contains(product.id);
              
              return GestureDetector(
                onTap: () async {
                  final refreshedData = await Navigator.push<Map<dynamic, dynamic>>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailMakanan(
                        result: product,
                        isStaff: false,
                        isAuthenticated: request.loggedIn, // Update this line to use request.loggedIn
                      ),
                    ),
                  );

                  if (refreshedData != null) {
                    // Handle the refreshedData if needed
                    print("Data returned from DetailMakanan: $refreshedData");
                  }

                  // Ensure no value is returned from this function
                },
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 2, // Ditambahkan elevation yang lebih halus
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Ditambahkan border radius
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 140, // Dikurangi dari 150
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
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => onWishlistToggle(product.id ?? 0),
                              child: Container(
                                padding: const EdgeInsets.all(6), // Dikurangi dari 8
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isInWishlist ? Icons.favorite : Icons.favorite_border,
                                  color: isInWishlist ? Colors.red : Colors.grey,
                                  size: 18, // Dikurangi dari 20
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                product.name ?? 'Unnamed Product',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12, // Dikurangi dari 13
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Rp${product.price ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12, // Dikurangi dari 13
                                ),
                              ),
                              const SizedBox(height: 2),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  final restaurantProducts = products.where(
                                    (p) => p.restaurantName == product.restaurantName
                                  ).toList();

                                  Navigator.push(
                                    context,
                                     MaterialPageRoute(
                                      builder: (context) => RestaurantDetailScreen(
                                        restaurant: RestaurantElement(
                                          id: -1, // Since we don't have this info from product
                                          name: product.restaurantName ?? '',
                                          kecamatan: product.kecamatan ?? '',
                                          location: product.location ?? '',
                                          menuCount: 1, // Default value since we don't have this info
                                          minPrice: '0',
                                          maxPrice: '0',
                                          avgPrice: '0',
                                          image: '', // We don't have restaurant image from product
                                          menus: [
                                            Menu(
                                              id: product.id ?? -1,
                                              name: product.name ?? '',
                                              price: product.price ?? '',
                                              image: product.image ?? '',
                                              category: product.category ?? '',
                                              description: product.description ?? '',
                                            )
                                          ],
                                        ),
                                        isStaff: true,
                                        isAuthenticated: true,
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.restaurant,
                                      size: 12, // Dikurangi dari 14
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        product.restaurantName ?? 'N/A',
                                        style: TextStyle(
                                          color: Colors.blue[700],
                                          fontSize: 11, // Dikurangi dari 12
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
                                    size: 12, // Dikurangi dari 14
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      product.kecamatan ?? 'N/A',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 11, // Dikurangi dari 12
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
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