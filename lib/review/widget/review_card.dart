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
    return SizedBox(
      width: 200, // Batasi lebar kartu
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Kurangi padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                review.user,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14, // Kurangi ukuran font
                ),
              ),
              const SizedBox(height: 4), // Kurangi jarak antar elemen
              Text(
                review.menuItem,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1, // Batasi jumlah baris
              ),
              const SizedBox(height: 4),
              Text(
                review.reviewText,
                maxLines: 2, // Batasi jumlah baris teks ulasan
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black87, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                'Rating: ${review.rating}/5',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Posted on: ${review.createdAt.toString().substring(0, 10)}',
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
      ),
    );
  }
}
