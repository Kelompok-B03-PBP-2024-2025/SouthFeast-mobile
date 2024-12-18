// lib/review/screens/review_form.dart

// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReviewFormPage extends StatefulWidget {
  final int menuItemId; // ID menu item yang direview

  const ReviewFormPage({super.key, required this.menuItemId});

  @override
  State<ReviewFormPage> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Fields for the form
  double _rating = 3.0;
  String _reviewText = '';

  bool _isLoading = false;

  // Ganti dengan URL backend Anda
  final String _backendUrl = 'https://southfeast-production.up.railway.app/review/create_review_flutter/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write Your Review'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Write Your Review
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Write Your Review',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your review';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _reviewText = value!;
                        },
                      ),
                      const SizedBox(height: 16.0),

                      // Rating Slider
                      Text(
                        'Rating: ${_rating.toStringAsFixed(1)}',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      Slider(
                        value: _rating,
                        min: 1.0,
                        max: 5.0,
                        divisions: 8, // Membagi slider menjadi 8 langkah (1.0, 1.5, ..., 5.0)
                        label: _rating.toStringAsFixed(1),
                        onChanged: (double value) {
                          setState(() {
                            _rating = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24.0),

                      // Submit Button
                      Center(
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('SUBMIT'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // Submit the form
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      // Membuat payload data review
      final Map<String, dynamic> reviewData = {
        'menu_item': widget.menuItemId,
        'rating': _rating,
        'review_text': _reviewText,
      };

      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {
          'Content-Type': 'application/json',
          // Tambahkan header otentikasi jika diperlukan
          // 'Authorization': 'Bearer YOUR_AUTH_TOKEN',
        },
        body: json.encode(reviewData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully')),
        );
        _formKey.currentState!.reset();
        setState(() {
          _rating = 3.0;
        });
        Navigator.pop(context); // Kembali ke halaman sebelumnya setelah sukses
      } else {
        // Untuk debugging: Cetak body response untuk melihat pesan error
        print('Failed to submit review: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit review')),
        );
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
