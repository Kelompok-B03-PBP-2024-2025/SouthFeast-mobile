// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
// import 'dart:io'; // Hapus import ini
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

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

  XFile? _selectedImage;
  String? _uploadedImageUrl; // Menyimpan URL gambar setelah upload

  /// Fungsi untuk pilih foto dari gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = 
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
        _uploadedImageUrl = null; // Reset URL gambar yang diupload sebelumnya
      });
    }
  }

  /// Fungsi untuk submit data ke Django via base64
  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final reviewText = _reviewTextController.text.trim();
    final rating = _ratingController.text.trim();

    // Ubah gambar ke base64 jika ada
    String? base64Image;
    if (_selectedImage != null) {
      final bytes = await _selectedImage!.readAsBytes();
      base64Image = base64Encode(bytes);
    }

    // Payload JSON
    final Map<String, dynamic> requestBody = {
      "menu_item_id": widget.menuItemId,
      "review_text": reviewText,
      "rating": rating,
      "image": base64Image, // null jika tidak ada gambar
    };

    try {
      // Ganti URL ini dengan endpoint Django Anda
      final url = Uri.parse('https://southfeast-production.up.railway.app/review/createreview/');

      // Kirim body JSON (bukan multipart)
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          // Jika butuh auth token, tambahkan di sini:
          // "Authorization": "Bearer <token>"
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Asumsikan Django membalas {"status": "success", "review_image_url": "<url>"}
        final jsonResp = jsonDecode(response.body);
        if (jsonResp["status"] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Review created successfully!")),
          );
          if (jsonResp["review_image_url"] != null) {
            setState(() {
              _uploadedImageUrl = jsonResp["review_image_url"];
              _selectedImage = null; // Reset gambar lokal setelah upload
            });
          }
          Navigator.pop(context, true); // Mengembalikan nilai true untuk refresh
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${jsonResp["status"]}")),
          );
        }
      } else {
        // Jika bukan 200, misal 401 atau error lain
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
              const SizedBox(height: 16),

              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _uploadedImageUrl != null
                      ? Image.network(
                          _uploadedImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Text("Failed to load image"));
                          },
                        )
                      : (_selectedImage != null
                          ? const Center(child: Text("Image will be displayed after upload"))
                          : const Center(child: Text("Tap to pick an image (optional)"))),
                ),
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
