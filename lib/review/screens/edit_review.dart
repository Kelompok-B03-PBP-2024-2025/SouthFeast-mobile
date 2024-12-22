// lib/review/screens/edit_review.dart

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:southfeast_mobile/review/models/review_entry.dart';

class EditReviewPage extends StatefulWidget {
  final ReviewEntry review;

  const EditReviewPage({super.key, required this.review});

  @override
  State<EditReviewPage> createState() => _EditReviewPageState();
}

class _EditReviewPageState extends State<EditReviewPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _reviewTextController;
  late TextEditingController _ratingController;

  @override
  void initState() {
    super.initState();
    _reviewTextController = TextEditingController(text: widget.review.reviewText);
    _ratingController = TextEditingController(text: widget.review.rating.toString());
  }

  Future<void> _submitEdit() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedReviewText = _reviewTextController.text.trim();
    final updatedRating = _ratingController.text.trim();

    final Map<String, dynamic> requestBody = {
      "review_text": updatedReviewText,
      "rating": updatedRating,
    };

    try {
      final url = Uri.parse('https://southfeast-production.up.railway.app/review/edit_review/${widget.review.id}/');

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          // Tambahkan header otentikasi jika diperlukan, misalnya:
          // "Authorization": "Bearer <token>",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonResp = jsonDecode(response.body);
        if (jsonResp["status"] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Review updated successfully!")),
          );
          Navigator.pop(context, true); // Mengembalikan nilai true untuk refresh
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${jsonResp["status"]}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unknown error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Exception: $e")),
      );
    }
  }

  @override
  void dispose() {
    _reviewTextController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Review"),
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
                onPressed: _submitEdit,
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
