import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:http/http.dart' as http;
import 'package:southfeast_mobile/restaurant/services/restaurant_service.dart';
import 'package:southfeast_mobile/restaurant/screens/restaurant_detail.dart';
import 'package:southfeast_mobile/screens/root_page.dart';
import 'package:southfeast_mobile/dashboard/screens/restaurant_detail_screen.dart';
import 'package:southfeast_mobile/review/models/review_entry.dart';
import 'package:southfeast_mobile/review/screens/detail_review.dart';
import 'package:southfeast_mobile/dashboard/models/product/product.dart';
import 'package:southfeast_mobile/dashboard/models/product/result.dart';
import 'package:southfeast_mobile/product/screens/detail_makanan.dart';
import 'package:southfeast_mobile/product/screens/product.dart';

class DummyArticle {
  final String image;
  final String title;
  final String content;
  DummyArticle({required this.image, required this.title, required this.content});
}

class DummyRestaurant {
  final String image;
  final String name;
  final String address;
  DummyRestaurant({required this.image, required this.name, required this.address});
}

class DummyReview {
  final String username;
  final double rating;
  final String text;
  final String? image;
  DummyReview({required this.username, required this.rating, required this.text, this.image});
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentImageIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final List<String> _heroImages = [
    'https://manual.co.id/wp-content/uploads/2024/04/1317_solo_ristorante_web-980x719.jpg',
    'https://manual.co.id/wp-content/uploads/2024/06/nothing-personal_57-980x719.jpg',
    'https://manual.co.id/wp-content/uploads/2024/05/Sando-Shop_29-980x719.jpg',
  ];

  final List<DummyArticle> articles = [
    DummyArticle(
      image: 'https://manual.co.id/wp-content/uploads/2023/12/scarlett_461-980x719.jpg',
      title: 'Best Restaurants in South Jakarta',
      content: 'Discover the hidden gems of South Jakarta\'s culinary scene...',
    ),
    DummyArticle(
      image: 'https://manual.co.id/wp-content/uploads/2020/01/LawlessMenteng_Di-4-980x719.jpg',
      title: 'Street Food Guide',
      content: 'Exploring the vibrant street food culture of Jakarta...',
    ),
    DummyArticle(
      image: 'https://manual.co.id/wp-content/uploads/2024/05/Sando-Shop_29-980x719.jpg',
      title: 'Coffee Shop Reviews',
      content: 'The best coffee shops in South Jakarta for your caffeine fix...',
    ),
  ];

  final List<DummyRestaurant> restaurants = [
    DummyRestaurant(
      image: 'https://manual.co.id/wp-content/uploads/2023/12/scarlett_461-980x719.jpg',
      name: 'Scarlett House',
      address: 'Jl. Sultan Hasanudin Dalam, Blok M',
    ),
    DummyRestaurant(
      image: 'https://manual.co.id/wp-content/uploads/2020/01/LawlessMenteng_Di-4-980x719.jpg',
      name: 'Lawless Burger',
      address: 'Jl. Kemang Selatan VIII',
    ),
    DummyRestaurant(
      image: 'https://lh3.googleusercontent.com/p/AF1QipPBOBazDd1VtTo_AWYMPlzDEdeO6NTvMpeAJxq6=s1360-w1360-h1020',
      name: 'Saigon Street Food',
      address: 'Jl. Tebet Barat I',
    ),
  ];

  final List<int> restaurantIds = [46, 36, 26]; // Added restaurant IDs
  late Future<List<ReviewEntry>> _reviewsFuture;
  late Future<List<Result>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = fetchReviews();
    _productsFuture = fetchProducts();
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _heroImages.length;
        });
      }
    });
  }

  Future<List<ReviewEntry>> fetchReviews() async {
    try {
      const baseUrl = 'https://southfeast-production.up.railway.app/review/json/';
      final url = Uri.parse(baseUrl);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final allReviews = reviewEntryFromJson(response.body);
        // Take only first 5 reviews
        return allReviews.take(5).toList();
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Result>> fetchProducts() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'https://southfeast-production.up.railway.app/dashboard/show-json/?page=1'
      );
      
      if (response != null) {
        final Product productData = Product.fromMap(response);
        return productData.results ?? [];
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      extendBody: true,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Hero Section
            Stack(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    key: ValueKey<String>(_heroImages[_currentImageIndex]),
                    height: screenSize.height, // Changed from screenSize.height * 0.8
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(_heroImages[_currentImageIndex]),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Food & Drink',
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 16),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'get Lost. ',
                                      style: TextStyle(
                                        fontFamily: 'La Belle Aurore',
                                        fontSize: isSmallScreen ? 32 : 48,
                                        color: Colors.white,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Find South Jakarta',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 32 : 48,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  side: const BorderSide(color: Colors.white),
                                ),
                                onPressed: () {
                                  _scrollController.animateTo(
                                    screenSize.height, // Changed from screenSize.height * 0.8
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: const Text(
                                  'See More',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Articles Section
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    "Explore South Jakarta's Culinary Delights",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Discover the hidden gems and popular spots that make South Jakarta a food paradise.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (isSmallScreen) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8),
                                    ),
                                    child: Image.network(
                                      articles[index].image,
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: _buildArticleContent(articles[index]),
                                  ),
                                ],
                              );
                            } else {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomLeft: Radius.circular(8),
                                    ),
                                    child: Image.network(
                                      articles[index].image,
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: _buildArticleContent(articles[index]),
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Restaurants Section
            Container(
              color: Colors.black,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Explore The Neighborhood',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 24 : 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          final request = context.read<CookieRequest>();
                          bool isAuthenticated = request.loggedIn;
                          bool isStaff = request.jsonData?['is_staff'] ?? false;
                          
                          if (isStaff) {
                            // For staff, navigate to RootPage with dashboard index
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RootPage(
                                  isStaff: isStaff,
                                  isAuthenticated: isAuthenticated,
                                  initialIndex: 1, // Dashboard index
                                  showRestaurants: true, // Add this parameter to show restaurants
                                ),
                              ),
                              (route) => false,
                            );
                          } else {
                            // For non-staff, navigate to regular restaurant page
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RootPage(
                                  isStaff: false,
                                  isAuthenticated: isAuthenticated,
                                  initialIndex: 2,
                                ),
                              ),
                              (route) => false,
                            );
                          }
                        },
                        child: const Text(
                          'See All →',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isSmallScreen ? 1 : 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isSmallScreen ? 1.2 : 0.8,
                    ),
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () async {
                          final request = context.read<CookieRequest>();
                          bool isStaff = request.jsonData?['is_staff'] ?? false;
                          try {
                            final restaurant = await RestaurantService.fetchRestaurantDetail(
                              request,
                              restaurantIds[index],
                            );
                            if (mounted) {
                              if (isStaff) {
                                // Staff users go to dashboard restaurant detail
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RestaurantDetailAdmin(
                                      restaurant: restaurant,
                                      isStaff: true,
                                      isAuthenticated: true,
                                    ),
                                  ),
                                );
                              } else {
                                // Regular users go to customer restaurant detail
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RestaurantDetailScreen(
                                      restaurant: restaurant,
                                      isAuthenticated: request.loggedIn,
                                    ),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to load restaurant details'),
                              ),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                  child: Image.network(
                                    restaurants[index].image,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      restaurants[index].name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      restaurants[index].address,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Add spacing between sections
            const SizedBox(height: 32),

            // Products Section (only for non-admin users)
            if (!(context.read<CookieRequest>().jsonData?['is_staff'] ?? false))
              _buildProductsSection(),

            // Reviews Section
            Container(
              color: Colors.black, // Changed to black
              padding: const EdgeInsets.all(24), // Removed bottomPadding
              child: Column(
                children: [
                  const Text(
                    'User Reviews',
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Added white color
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'See what others are saying about our menu items.',
                    style: TextStyle(color: Colors.white70), // Changed to white70
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 280,
                    child: FutureBuilder<List<ReviewEntry>>(
                      future: _reviewsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No reviews available'));
                        }

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final review = snapshot.data![index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailReviewPage(
                                      review: review,
                                      isStaff: context.read<CookieRequest>().jsonData?['is_staff'] ?? false,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: isSmallScreen ? screenSize.width * 0.8 : 300,
                                margin: const EdgeInsets.only(right: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          review.user,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Row(
                                          children: List.generate(
                                            5,
                                            (i) => Icon(
                                              Icons.star,
                                              size: 16,
                                              color: i < review.rating ? Colors.amber : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      review.reviewText,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: review.reviewImage != null
                                          ? Image.network(
                                              review.reviewImage!,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              errorBuilder: (context, error, stackTrace) =>
                                                Image.network(
                                                  'https://southfeast-production.up.railway.app/static/image/default-review.jpg',
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                ),
                                            )
                                          : Image.network(
                                              'https://southfeast-production.up.railway.app/static/image/default-review.jpg',
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Add bottom spacing to prevent navbar overlap
            const SizedBox(height: 100), // Added fixed bottom spacing

          ],
        ),
      ),
    );
  }

  Widget _buildProductsSection() {
    return Container(
      color: Colors.white, // Changed to white
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Related Products',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Changed to black
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final request = context.read<CookieRequest>();
                    bool isAuthenticated = request.loggedIn;
                    bool isStaff = request.jsonData?['is_staff'] ?? false;
                    
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RootPage(
                          isStaff: isStaff,
                          isAuthenticated: isAuthenticated,
                          initialIndex: 1, // Product page index
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'See All Products →',
                    style: TextStyle(color: Colors.black), // Changed to black
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: FutureBuilder<List<Result>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No products available'));
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final product = snapshot.data![index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailMakanan(
                              result: product,
                              isStaff: false,
                              isAuthenticated: context.read<CookieRequest>().loggedIn,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: Colors.white, // Changed to white
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                              child: Image.network(
                                product.image ?? 'https://via.placeholder.com/150',
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name ?? 'No name',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black, // Changed to black
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp ${product.price}',
                                    style: const TextStyle(
                                      color: Colors.black, // Changed to black
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    product.restaurantName ?? 'Unknown restaurant',
                                    style: const TextStyle(
                                      color: Colors.grey, // Changed to grey
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleContent(DummyArticle article) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Food and Beverage',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          article.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          article.content,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}