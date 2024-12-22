// lib/review/screens/review.dart

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:southfeast_mobile/review/models/review_entry.dart';
import 'package:southfeast_mobile/review/widget/review_card.dart'; // Pastikan path benar

class ReviewPage extends StatefulWidget {
  final bool isStaff;
  final bool isAuthenticated;
  final String? username;

  const ReviewPage({
    super.key,
    this.isStaff = false,
    this.isAuthenticated = false,
    this.username,
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late Future<List<ReviewEntry>> _reviewsFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reviewsFuture = fetchReviews();
  }

  Future<List<ReviewEntry>> fetchReviews([String query = '']) async {
    try {
      const baseUrl = 'https://southfeast-production.up.railway.app/review/json/';
      final url = Uri.parse('$baseUrl?search=$query');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return reviewEntryFromJson(response.body);
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (e) {
      rethrow;
    }
  }

  void _onSearch() {
    setState(() {
      _reviewsFuture = fetchReviews(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context),
            FutureBuilder<List<ReviewEntry>>(
              future: _reviewsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return SizedBox(
                    height: 300,
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SizedBox(
                    height: 300,
                    child: Center(
                      child: Text(
                        'No reviews found for "${_searchController.text}"',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                } else {
                  final reviews = snapshot.data!;
                  return _buildReviewsSection(context, reviews);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        // Background Image
        SizedBox(
          height: screenHeight * 0.5,
          width: double.infinity,
          child: Image.network(
            'https://manual.co.id/wp-content/uploads/2020/07/roma_osteria_sequis-4-980x719.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Container(
          height: screenHeight * 0.5,
          width: double.infinity,
          color: Colors.black.withOpacity(0.5),
        ),
        Positioned.fill(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Reviews',
                  style: TextStyle(
                    fontFamily: 'La Belle Aurore',
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'These reviews don’t lie – this place won’t disappoint!',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: Colors.white),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    // Aksi tombol "See Reviews" (mis. scroll ke bawah)
                  },
                  child: const Text('See Reviews'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(
      BuildContext context, List<ReviewEntry> reviews) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          const Text(
            'Reviews',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 16),
          _buildReviewGrid(context, reviews),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for reviews by food or content...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _onSearch,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: const Text('Search'),
        ),
      ],
    );
  }

  Widget _buildReviewGrid(BuildContext context, List<ReviewEntry> reviews) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final maxWidth = constraints.maxWidth;
        int crossAxisCount = 1;
        if (maxWidth > 900) {
          crossAxisCount = 3;
        } else if (maxWidth > 600) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (context, index) {
            final review = reviews[index];
            return ReviewCard(
              review: review,
              isStaff: widget.isStaff,
              currentUsername: widget.username, // Kirimkan username saat ini
            );
          },
        );
      },
    );
  }
}
