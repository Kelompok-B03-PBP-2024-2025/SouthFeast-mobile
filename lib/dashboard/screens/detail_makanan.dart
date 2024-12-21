import 'package:flutter/material.dart';
import 'package:southfeast_mobile/dashboard/models/product/result.dart';
import 'package:southfeast_mobile/dashboard/screens/edit_makanan.dart';

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

  const DetailMakanan({
    Key? key, 
    required this.result,
    this.onUpdate, required bool isStaff, required bool isAuthenticated,
  }) : super(key: key);

  @override
  State<DetailMakanan> createState() => _DetailMakananState();
}

class _DetailMakananState extends State<DetailMakanan> {
  late Result currentResult;

  @override
  void initState() {
    super.initState();
    currentResult = widget.result;
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
      setState(() {
        currentResult = editResult as Result;
      });
      if (widget.onUpdate != null) {
        widget.onUpdate!();
      }
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
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

    if (confirm == true) {
      // TODO: Implement delete functionality
      print('Delete confirmed');
      Navigator.of(context).pop(); // Return to previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dummy reviews data
    final List<Review> reviews = [
      Review(
        userName: "John Doe",
        rating: 4.5,
        comment: "Great food! Really enjoyed it.",
        date: "2023-12-01",
      ),
      Review(
        userName: "Jane Smith",
        rating: 5.0,
        comment: "Amazing taste and presentation!",
        date: "2023-11-30",
      ),
    ];

    return Scaffold(
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
                currentResult.image ?? '',
                fit: BoxFit.cover,
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
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.delete, size: 18),
                            label: const Text('Delete'),
                            onPressed: () => _handleDelete(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      InfoRow(title: 'Kecamatan', value: currentResult.kecamatan),
                      InfoRow(title: 'Restaurant', value: currentResult.restaurantName),
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
                  margin: const EdgeInsets.all(16),
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
                      ...reviews.map((review) => ReviewCard(review: review)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
  final Review review;

  const ReviewCard({Key? key, required this.review}) : super(key: key);

  Future<void> _handleDeleteReview(BuildContext context) async {
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
      // TODO: Implement review deletion
      print('Review deletion confirmed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        review.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Text(
                            ' ${review.rating}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 18),
                            color: Colors.red,
                            onPressed: () => _handleDeleteReview(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              review.date,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
