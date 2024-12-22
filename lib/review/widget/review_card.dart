// lib/widgets/review_card.dart

import 'package:flutter/material.dart';
import 'package:southfeast_mobile/review/models/review_entry.dart';
import 'package:southfeast_mobile/review/screens/detail_review.dart';

class ReviewCard extends StatelessWidget {
  final ReviewEntry review;
  final bool isStaff;

  const ReviewCard({
    super.key,
    required this.review,
    this.isStaff = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: (review.reviewImage != null)
                ? Image.network(
                    review.reviewImage!,
                    fit: BoxFit.cover,
                    // Jika gambar error, gunakan fallback
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        'https://southfeast-production.up.railway.app/static/image/default-review.jpg',
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.network(
                    'https://southfeast-production.up.railway.app/static/image/default-review.jpg',
                    fit: BoxFit.cover,
                  ),
          ),
          // Konten
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris: user + rating
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
                // Review text (truncated)
                Text(
                  review.reviewText,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 8),
                // Tanggal
                Text(
                  'Posted on: ${review.createdAt.toString().substring(0, 10)}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                // Tombol "View More"
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Tampilkan detail review
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
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
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
