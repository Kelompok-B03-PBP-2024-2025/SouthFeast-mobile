// review_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:southfeast_mobile/review/models/reviewentry.dart';
import 'package:southfeast_mobile/review/screens/detail_review.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  // Fetch data review dari API
  Future<List<ReviewEntry>> fetchReviews(CookieRequest request) async {
    final response = await request.get('https://southfeast-production.up.railway.app/review/json/'); // URL API yang menampilkan data review
    
    // Melakukan decode response menjadi bentuk json dan parsing ke ReviewEntry
    return reviewEntryFromJson(json.encode(response));
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review List'),
      ),
      body: FutureBuilder<List<ReviewEntry>>(
        future: fetchReviews(request),
        builder: (context, AsyncSnapshot<List<ReviewEntry>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No reviews found.'));
          } else {
            final reviews = snapshot.data!;
            return ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (_, index) {
                final review = reviews[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewDetailPage(review),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Rating dan Review Title
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${review.rating}",
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          
                          // Display review text
                          Text(
                            review.reviewText,
                            style: const TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                          const SizedBox(height: 10),

                          // Product Name
                          Text(
                            "Product: ${review.menuItem}",
                            style: const TextStyle(fontSize: 14, color: Colors.black45),
                          ),
                          const SizedBox(height: 10),
                          
                          // Display image URL if available
                          if (review.imageUrl != null && review.imageUrl.toString().isNotEmpty)
                            Image.network(
                              review.imageUrl!,
                              fit: BoxFit.cover,
                              height: 150,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Text("Error loading image"),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
