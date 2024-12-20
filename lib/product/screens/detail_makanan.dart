import 'package:flutter/material.dart';
import 'package:southfeast_mobile/dashboard/models/product/result.dart';
import 'package:southfeast_mobile/review/screens/review_form.dart'; // Impor ReviewFormPage

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

  const DetailMakanan({
    super.key,
    required this.result,
  });

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

  // Fungsi untuk navigasi ke ReviewFormPage dengan mengirimkan menuItemId
  void _navigateToReviewForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewFormPage(menuItemId: currentResult.id ?? 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    currentResult.name ?? 'No Name',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 4),
                        blurRadius: 15,
                        color: Colors.black.withOpacity(0.5),
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

                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 4),
                        blurRadius: 15,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
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
                      ...reviews.map((review) => ReviewCard(review: review)).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Button "Add Review"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _navigateToReviewForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ), // Warna latar belakang tombol
                      ),
                      child: const Text(
                        'Add Review',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Memberikan ruang di bawah tombol
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
            width: 100,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value ?? 'Not Available',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
              textAlign: TextAlign.left,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan nama pengguna dan rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${review.rating}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Komentar review
            Text(
              review.comment,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 4),
            // Tanggal review
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
