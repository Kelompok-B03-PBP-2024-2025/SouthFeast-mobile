import 'package:flutter/material.dart';
import 'package:southfeast_mobile/dashboard/models/product/result.dart';
import 'package:southfeast_mobile/dashboard/screens/edit_makanan.dart';
import 'package:southfeast_mobile/widgets/custom_bottom_nav.dart';
import 'package:southfeast_mobile/authentication/screens/login.dart';
import 'package:southfeast_mobile/config/menu_config.dart';  // Add this import
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:southfeast_mobile/review/models/review_entry.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Dummy Review Model (To be replaced with actual model later)
class Review {
  final String userName;
  final double rating;
  final String comment;
  final String date;

  Review({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class DetailMakanan extends StatefulWidget {
  final Result result;
  final Function? onUpdate;
  final bool isStaff;
  final bool isAuthenticated;

  const DetailMakanan({
    Key? key,
    required this.result,
    this.onUpdate,
    required this.isStaff,
    required this.isAuthenticated,
  }) : super(key: key);

  @override
  State<DetailMakanan> createState() => _DetailMakananState();
}

class _DetailMakananState extends State<DetailMakanan> {
  late Result currentResult;
  // Update index calculation to match Dashboard position
  late int _selectedIndex = widget.isStaff ? 1 : 0;
  late Future<List<ReviewEntry>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    currentResult = widget.result; // Initialize currentResult first
    _reviewsFuture = fetchReviews(); // Then call fetchReviews
  }

  Future<List<ReviewEntry>> fetchReviews() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'https://southfeast-production.up.railway.app/dashboard/get-reviews-flutter/${currentResult.id}/',
      );

      if (response != null) {
        if (response is Map) {
          final List<dynamic> reviewsJson = response['reviews'];
          return reviewsJson.map((reviewJson) => ReviewEntry(
            id: reviewJson['id'],
            menuItem: currentResult.name ?? '',
            user: reviewJson['user'],
            reviewText: reviewJson['content'],
            rating: reviewJson['rating'].toDouble(),
            reviewImage: reviewJson['image'],
            createdAt: DateTime.parse(reviewJson['created_at']),
          )).toList();
        }
      }
      throw Exception('Invalid response format');
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      // Return to previous page if different index is selected
      Navigator.pop(context);
    }
  }

  void _handleEdit(BuildContext context) async {
    final editResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMakananForm(
          makanan: {
            'id': currentResult.id,
            'name': currentResult.name,
            'description': currentResult.description,
            'price': currentResult.price,
            'image': currentResult.image,
            'category': currentResult.category,
            'restaurant_name': currentResult.restaurantName,
            'kecamatan': currentResult.kecamatan,
            'location': currentResult.location,
          },
        ),
      ),
    );

    if (editResult != null) {
      // Convert the edit result to a Result object
      setState(() {
        currentResult = Result(
          id: editResult['id'],
          name: editResult['name'],
          description: editResult['description'],
          price: editResult['price'],
          image: editResult['image'],
          category: editResult['category'],
          restaurantName: editResult['restaurant_name'],
          kecamatan: editResult['kecamatan'],
          location: editResult['location'],
        );
      });
      if (widget.onUpdate != null) {
        widget.onUpdate!();
      }
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final request = context.read<CookieRequest>();
    final bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Confirm Delete',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to delete this item?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true && context.mounted) {
      final response = await request.get(
        'https://southfeast-production.up.railway.app/dashboard/delete-makanan-flutter/${currentResult.id}/',
      );
      if (response['status'] == 'success') {
        if (widget.onUpdate != null) {
          widget.onUpdate!();
        }
        if (context.mounted) {
          Navigator.pop(context, true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the bottom navigation bar height
    final bottomNavHeight = MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight;

    return Scaffold(
      extendBody: true,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                (currentResult.image != null && currentResult.image!.isNotEmpty)
                    ? currentResult.image!
                    : 'https://southfeast-production.up.railway.app/static/image/default-review.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.network(
                    'https://southfeast-production.up.railway.app/static/image/default-review.jpg',
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Title Section with Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Text(
                        currentResult.name ?? 'No Name',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Edit'),
                            onPressed: () => _handleEdit(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 0, 32, 70),
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.delete, size: 18),
                            label: const Text('Delete'),
                            onPressed: () => _handleDelete(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 97, 2, 0),
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
      
                // Combined Details & Description Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 4),
                        blurRadius: 15,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(color: Colors.grey),
                      InfoRow(title: 'Category', value: currentResult.category),
                      InfoRow(title: 'Price', value: currentResult.price),
                      InfoRow(
                          title: 'Kecamatan', value: currentResult.kecamatan),
                      InfoRow(
                          title: 'Restaurant',
                          value: currentResult.restaurantName),
                      InfoRow(title: 'Location', value: currentResult.location),
                      const SizedBox(height: 20),
                      const Text(
                        'Description',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(color: Colors.grey),
                      Text(
                        currentResult.description ?? 'No Description',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
      
                // Reviews Section
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: EdgeInsets.fromLTRB(16, 16, 16, bottomNavHeight + 16), // Add bottom padding
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reviews',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(color: Colors.grey),
                      FutureBuilder<List<ReviewEntry>>(
                        future: _reviewsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('No reviews yet', style: TextStyle(color: Colors.white));
                          }
                          
                          return Column(
                            children: snapshot.data!.map((review) => ReviewCard(
                              review: review,
                              isStaff: widget.isStaff,
                            )).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        menuItems: MenuConfig.getMenuItems(
          isStaff: widget.isStaff,
          isAuthenticated: widget.isAuthenticated,
          username: null, // Add username if needed
        ),
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
        isAuthenticated: widget.isAuthenticated,
        onAuthCheck: (context, item) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
      ),
    );
  }
}

// Update InfoRow to match dark theme
class InfoRow extends StatelessWidget {
  final String title;
  final String? value;

  const InfoRow({Key? key, required this.title, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100, // Fixed width for title
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(width: 12), // Space between title and value
          Expanded(
            child: Text(
              value ?? 'Not Available',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
              textAlign: TextAlign.left,
              overflow: TextOverflow.visible, // Allow text to wrap
            ),
          ),
        ],
      ),
    );
  }
}

// New Review Card Widget
class ReviewCard extends StatelessWidget {
  final ReviewEntry review;
  final bool isStaff;

  const ReviewCard({
    Key? key, 
    required this.review,
    required this.isStaff,
  }) : super(key: key);

  Future<void> _handleDeleteReview(BuildContext context) async {
    final request = context.read<CookieRequest>();
    final bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Delete Review',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to delete this review?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final response = await request.get(
          'https://southfeast-production.up.railway.app/dashboard/delete-review-flutter/${review.id}/',
        );

        if (response['status'] == 'success') {
          // Refresh the parent widget to update the reviews list
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Review deleted successfully'),
                backgroundColor: Colors.black,
              ),
            );
            // Find the DetailMakanan widget and refresh reviews
            final detailMakananState = context.findAncestorStateOfType<_DetailMakananState>();
            if (detailMakananState != null) {
              detailMakananState.setState(() {
                detailMakananState._reviewsFuture = detailMakananState.fetchReviews();
              });
            }
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to delete review'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const String defaultImageUrl = 'https://southfeast-production.up.railway.app/static/image/default-review.jpg';
    
    Widget buildImageWidget() {
      // If reviewImage is null, don't show any image section
      if (review.reviewImage == null) {
        return const SizedBox.shrink();
      }

      // If reviewImage is empty string, show default image
      if (review.reviewImage!.isEmpty) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            defaultImageUrl,
            width: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.white54,
                  size: 32,
                ),
              ),
            ),
          ),
        );
      }

      // If reviewImage has a value, try to load it with fallback to default
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          review.reviewImage!,
          width: double.infinity,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Image.network(
            defaultImageUrl,
            width: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.white54,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info and rating section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review.user,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    Text(
                      ' ${review.rating}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    if (isStaff) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18),
                        color: Colors.red,
                        onPressed: () => _handleDeleteReview(context),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Review text
            Text(
              review.reviewText,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            
            // Review date
            Text(
              review.createdAt.toString().substring(0, 10),
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            
            // Image section - only show if reviewImage is not null
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: buildImageWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
