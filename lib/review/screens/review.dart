import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

// Import model ReviewEntry
import 'package:southfeast_mobile/review/models/review_entry.dart';
import 'package:southfeast_mobile/review/screens/detail_review.dart';

class ReviewPage extends StatefulWidget {
  // Parameter opsional jika Anda ingin melewatkan info login, dsb.
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

  /// Contoh fungsi untuk mengambil data review dari API Django
  Future<List<ReviewEntry>> fetchReviews([String query = '']) async {
      try {
    // Misal endpoint Anda: https://example.com/review/show_json/
    // Lalu kita tambahkan query param `search` untuk filtering (opsional).
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
      // Body page untuk menampilkan reviews
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
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return SizedBox(
                    height: 300,
                    child: Center(
                      child: Text('Error: ${snapshot.error}'),
                    ),
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

  // Bagian hero, meniru tampilan background + teks di Django
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
        // Overlay warna hitam
        Container(
          height: screenHeight * 0.5,
          width: double.infinity,
          color: Colors.black.withOpacity(0.5),
        ),
        // Tulisan
        Positioned.fill(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Reviews',
                  style: TextStyle(
                    fontFamily: 'La Belle Aurore', // Pastikan font terinstall
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
                    // Scroll ke review section
                    // Cara paling sederhana: Scrollable.ensureVisible(...)
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

  // Bagian untuk menampilkan Search Bar + Grid Review
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

  // Search Bar
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

  // Grid Review
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
            return _buildReviewCard(review);
          },
        );
      },
    );
  }

  // Card satuan Review
  Widget _buildReviewCard(ReviewEntry review) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      // Layout card
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Bagian gambar
          Expanded(
            child: review.reviewImage != null
                ? Image.network(
                    review.reviewImage!,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/default-review.jpg', // fallback local image
                    fit: BoxFit.cover,
                  ),
          ),
          // Bagian konten
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris user + rating
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
                    Text(
                      'Rating: ${review.rating}/5',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Menu item
                Text(
                  review.menuItem,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Truncated review text
                Text(
                  review.reviewText,
                  maxLines: 3, // meniru truncate multiple lines
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 8),

                // Tanggal (createdAt)
                Text(
                  'Posted on: ${review.createdAt.toString().substring(0, 10)}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),

                // Tombol
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailReviewPage(
                              review: review, 
                              isStaff: widget.isStaff,         // Opsional jika Anda ingin menampilkan tombol "Delete" hanya untuk staff
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'View More',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    // Kondisional jika user == current user (untuk edit)
                    // ElevatedButton(
                    //   onPressed: () {
                    //     // Navigate ke edit page
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.black,
                    //     foregroundColor: Colors.white,
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: 8, vertical: 4),
                    //   ),
                    //   child: const Text('Edit Review'),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}