// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:southfeast_mobile/review/models/review_entry.dart';
import 'package:southfeast_mobile/review/screens/edit_review.dart';

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
      margin: const EdgeInsets.all(8.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User and Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review.user,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${review.rating}/5",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Review Text
            Text(
              review.reviewText,
              style: const TextStyle(fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 16),

            // Review Image
            if (review.reviewImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  review.reviewImage!,
                  fit: BoxFit.cover,
                  height: 150,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      height: 150,
                      child: const Center(
                        child: Text("Failed to load image"),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),

            // Action Buttons
            if (showEditButton || isStaff)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (showEditButton)
                    ElevatedButton.icon(
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
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text("Edit"),
                    ),
                  if (isStaff)
                    ElevatedButton.icon(
                      onPressed: () {
                        _showDeleteConfirmation(context, review.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text("Delete"),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int reviewId) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this review?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                _deleteReview(context, reviewId);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _deleteReview(BuildContext context, int reviewId) async {
    try {
      // Call API to delete review
      // Replace with your API delete call
      final success = await _callDeleteAPI(reviewId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Review deleted successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete review.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  Future<bool> _callDeleteAPI(int reviewId) async {
    // Simulate API call
    // Replace with actual API call logic
    await Future.delayed(const Duration(seconds: 1));
    return true; // Return true if successful, false otherwise
  }
}
