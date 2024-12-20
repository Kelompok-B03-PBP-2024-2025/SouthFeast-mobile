import 'package:flutter/material.dart';
import 'package:southfeast_mobile/review/models/reviewentry.dart'; // Pastikan ReviewEntry sudah didefinisikan di folder models

class ReviewDetailPage extends StatelessWidget {
  final ReviewEntry review; // Menerima objek ReviewEntry yang dipilih

  const ReviewDetailPage(this.review, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Menampilkan menu item (nama produk)
              Text(
                'Menu Item: ${review.menuItem}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Menampilkan rating
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    '${review.rating}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Menampilkan nama pengguna
              Text(
                'User: ${review.user}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),

              // Menampilkan teks review
              Text(
                'Review: ${review.reviewText}',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 16),

              // Menampilkan image_url jika tersedia
              if (review.imageUrl != null && review.imageUrl.toString().isNotEmpty)
                Image.network(
                  review.imageUrl!,
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      const Text("Error loading image"),
                ),
              const SizedBox(height: 16),

              // Menampilkan tanggal review
              Text(
                'Reviewed on: ${review.createdAt.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(fontSize: 14, color: Colors.black45),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Anda bisa menyesuaikan ini sesuai kebutuhan
        onTap: (index) {
          // Menambahkan navigasi sesuai dengan index yang dipilih
          switch (index) {
            case 0:
              // Navigasi ke halaman Home
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              // Navigasi ke halaman Search
              Navigator.pushNamed(context, '/search');
              break;
            case 2:
              // Navigasi ke halaman Profile
              Navigator.pushNamed(context, '/profile');
              break;
            default:
              break;
          }
        },
        selectedItemColor: Colors.blue, // Warna item yang terpilih
        unselectedItemColor: Colors.grey, // Warna item yang tidak terpilih
        showUnselectedLabels: true, // Menampilkan label untuk item yang tidak terpilih
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
