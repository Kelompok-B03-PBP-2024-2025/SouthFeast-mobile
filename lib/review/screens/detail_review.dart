import 'package:flutter/material.dart';
import 'package:southfeast_mobile/review/models/reviewentry.dart';  // Pastikan ReviewEntry sudah didefinisikan di folder models

class ReviewDetailPage extends StatefulWidget {
  final ReviewEntry review;  // Menerima objek review yang dipilih

  const ReviewDetailPage(this.review, {super.key});

  @override
  _ReviewDetailPageState createState() => _ReviewDetailPageState();
}

class _ReviewDetailPageState extends State<ReviewDetailPage> {
  int _selectedIndex = 0;  // Untuk menyimpan index yang dipilih pada BottomNavigationBar

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menampilkan menu item (nama produk)
            Text(
              'Menu Item: ${widget.review.menuItem}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Menampilkan rating
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange),
                Text(
                  '${widget.review.rating}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Menampilkan nama pengguna
            Text(
              'User: ${widget.review.user}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),

            // Menampilkan teks review
            Text(
              'Review: ${widget.review.reviewText}',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 16),

            // Menampilkan gambar review jika ada
            if (widget.review.reviewImage != null)
              Image.network(
                widget.review.reviewImage!,
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              ),
            const SizedBox(height: 16),

            // Menampilkan tanggal review
            Text(
              'Reviewed on: ${widget.review.createdAt.toLocal()}',
              style: const TextStyle(fontSize: 14, color: Colors.black45),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Menandakan item yang dipilih
        onTap: _onItemTapped, // Menangani perubahan item yang dipilih
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
