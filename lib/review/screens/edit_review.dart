import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EditReviewPage extends StatefulWidget {
  final int reviewId; // ID ulasan untuk diedit
  final String initialReviewText; // Teks ulasan awal
  final double initialRating; // Rating awal

  const EditReviewPage({
    super.key,
    required this.reviewId,
    required this.initialReviewText,
    required this.initialRating,
  });

  @override
  State<EditReviewPage> createState() => _EditReviewPageState();
}

class _EditReviewPageState extends State<EditReviewPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _reviewTextController;
  late TextEditingController _ratingController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _reviewTextController = TextEditingController(text: widget.initialReviewText);
    _ratingController = TextEditingController(text: widget.initialRating.toString());
  }

  @override
  void dispose() {
    _reviewTextController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  /// Fungsi untuk mengirimkan perubahan ke backend
  Future<void> _submitEdit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final request = context.read<CookieRequest>();

      final response = await request.postJson(
        'https://southfeast-production.up.railway.app/review/createreview/${widget.reviewId}/',
        jsonEncode({
          'review_text': _reviewTextController.text.trim(),
          'rating': double.parse(_ratingController.text.trim()),
        }),
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review updated successfully!')),
        );
        Navigator.pop(context, true); // Kembali dengan status berhasil
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response['status']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Review'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Edit Your Review',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Form Edit Review Text
              TextFormField(
                controller: _reviewTextController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Edit Your Review',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your review';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Form Edit Rating
              TextFormField(
                controller: _ratingController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Rating (1-5)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a rating';
                  }
                  final rating = double.tryParse(value);
                  if (rating == null || rating < 1 || rating > 5) {
                    return 'Rating must be between 1 and 5';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tombol Save Changes
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitEdit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Changes'),
                ),
              ),

              const SizedBox(height: 16),

              // Tombol Cancel
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}