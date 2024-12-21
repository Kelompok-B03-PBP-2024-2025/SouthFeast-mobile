import 'package:flutter/material.dart';
import 'package:southfeast_mobile/review/models/review_entry.dart';

class DetailReviewPage extends StatelessWidget {
  final ReviewEntry review;
  final bool isStaff;

  const DetailReviewPage({
    super.key,
    required this.review,
    this.isStaff = false,
  });

  @override
  Widget build(BuildContext context) {
    // Di Django, "menu_item" adalah object yang punya "name", "description", "image".
    // Di model Flutter kita hanya menyimpan "menuItem" (String). 
    // Silakan sesuaikan jika Anda memiliki detail item terpisah.
    return Scaffold(
      appBar: AppBar(
        title: Text("${review.menuItem}'s Review"),
      ),
      body: SingleChildScrollView(
        child: Container(
          // Layout umum
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                "${review.menuItem}'s Review",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Product Preview Section (contoh, jika Anda punya data/URL gambar menu)
              // Misal di backend: review.menu_item.image
              // Kita pakai reviewImage atau "tidak ada" jika field menu punya data terpisah.
              _buildProductPreviewSection(),

              // Reviewer & Rating
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Reviewer: ${review.user}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Rating: ${review.rating}/5",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Review Text
              Text(
                review.reviewText,
                textAlign: TextAlign.justify,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),

              // Review Image (jika ada)
              if (review.reviewImage != null) ...[
                const SizedBox(height: 16),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      review.reviewImage!,
                      fit: BoxFit.cover,
                      // Batasi ukuran gambar
                      width: MediaQuery.of(context).size.width * 0.7,
                    ),
                  ),
                ),
              ],

              // Tombol Delete (jika staff = true)
              if (isStaff) ...[
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24, 
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      _showDeleteConfirmation(context);
                    },
                    child: const Text("Delete Review"),
                  ),
                ),
              ],

              // Tombol Back
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24, 
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Back to Reviews"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Contoh section untuk meniru "Product Preview"
  /// Anda mungkin punya detail menu item yang lebih lengkap.
  /// Di sini kita buat statik/palsu saja.
  Widget _buildProductPreviewSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Gambar produk (opsional)
          // Silakan ganti dengan data asli "menu_item.image" jika ada
          Container(
            width: 80,
            height: 80,
            color: Colors.grey.shade300,
            child: const Icon(
              Icons.restaurant,
              size: 40,
              color: Colors.black54,
            ),
          ),
          const SizedBox(width: 12),
          // Deskripsi produk
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.menuItem,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed euismod.",
                  style: TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    // Arahkan ke "Menu Details" jika ada halaman detail item
                    // Navigator.push( ... );
                  },
                  child: const Text(
                    "View Menu Details",
                    style: TextStyle(
                      color: Colors.pink,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Dialog Konfirmasi Delete
  void _showDeleteConfirmation(BuildContext context) {
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
                Navigator.pop(ctx); // Tutup dialog
                // TODO: Lakukan penghapusan review di backend
                // Misal panggil fungsi deleteReview(review.id) di sini
              },
              child: const Text("Delete"),
            )
          ],
        );
      },
    );
  }
}
