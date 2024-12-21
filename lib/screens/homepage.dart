import 'package:flutter/material.dart';
import 'dart:async';

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

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _heroImages.length;
        });
      }
    });
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
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80;

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
                          // Navigate to all restaurants
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
                      return Container(
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
                      );
                    },
                  ),
                ],
              ),
            ),

            // Reviews Section
            Container(
              color: Colors.grey[100],
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: 24 + bottomPadding,
              ),
              child: Column(
                children: [
                  const Text(
                    'User Reviews',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'See what others are saying about our menu items.',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Container(
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
                                  const Text(
                                    'John Doe',
                                    style: TextStyle(
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
                                        color: i < 4 ? Colors.amber : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Amazing food and great atmosphere! The service was exceptional and the prices were reasonable. Will definitely come back again.',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    'https://manual.co.id/wp-content/uploads/2023/12/scarlett_461-980x719.jpg',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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