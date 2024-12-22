import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ReviewFormPage extends StatefulWidget {
  final int menuItemId;

  const ReviewFormPage({
    super.key,
    required this.menuItemId,
  });

  @override
  State<ReviewFormPage> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _reviewTextController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();

  /// Function to submit review without image
  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final reviewText = _reviewTextController.text.trim();
    final rating = _ratingController.text.trim();

    // Get the request instance
    final request = context.read<CookieRequest>();

    try {
      // Send request to Django API
      final response = await request.postJson(
        'https://southfeast-production.up.railway.app/review/createreview/',
        jsonEncode({
          "menu_item_id": widget.menuItemId,
          "review_text": reviewText,
          "rating": rating,
          "image": null, // Ensure image is always null
        }),
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Review created successfully!")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response['status']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Exception: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Review"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Review Text
              TextFormField(
                controller: _reviewTextController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Review Text",
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Review text is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Rating
              TextFormField(
                controller: _ratingController,
                decoration: const InputDecoration(
                  labelText: "Rating (1-5)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Rating is required";
                  }
                  final rating = double.tryParse(val);
                  if (rating == null || rating < 1 || rating > 5) {
                    return "Rating must be between 1 and 5";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _submitReview,
                child: const Text("Submit Review"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
