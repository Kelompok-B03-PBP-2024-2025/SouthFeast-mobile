import 'package:flutter/material.dart';
import 'package:southfeast_mobile/review/models/review_entry.dart';
import 'package:southfeast_mobile/review/screens/edit_review.dart';
import 'package:southfeast_mobile/review/screens/detail_review.dart';

class ReviewCard extends StatelessWidget {
  final ReviewEntry review;
  final bool isStaff;
  final bool showEditButton;

  const ReviewCard({
    super.key,
    required this.review,
    this.isStaff = false,
    this.showEditButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(8.0), // Menambahkan margin untuk jarak antar kartu
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Mengatur padding sesuai kebutuhan
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nama Pengguna
            Text(
              review.user,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            // Nama Menu Item
            Text(
              review.menuItem,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              // Menghapus pembatasan jumlah baris agar teks dapat menyesuaikan
              // overflow: TextOverflow.ellipsis,
              // maxLines: 1,
            ),
            const SizedBox(height: 4),
            // Teks Ulasan
            Text(
              review.reviewText,
              // Mengizinkan teks ulasan untuk memiliki banyak baris sesuai konten
              // maxLines: null,
              // overflow: TextOverflow.visible,
              style: const TextStyle(color: Colors.black87, fontSize: 12),
            ),
            const SizedBox(height: 4),
            // Rating
            Text(
              'Rating: ${review.rating}/5',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            // Tanggal Posting
            Text(
              'Posted on: ${review.createdAt.toString().substring(0, 10)}',
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
            const SizedBox(height: 8),
            // Tombol Aksi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tombol "View More"
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailReviewPage(
                          review: review,
                          isStaff: isStaff,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'View More',
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
                // Tombol "Edit" (jika diizinkan)
                if (showEditButton)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditReviewPage(
                            reviewId: review.id,
                            initialReviewText: review.reviewText,
                            initialRating: review.rating,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
