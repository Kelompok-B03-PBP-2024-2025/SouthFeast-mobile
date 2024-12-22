import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/article_page.dart';
import 'article_detail.dart';
import 'article_form.dart';
import 'package:southfeast_mobile/authentication/screens/login.dart';
import '../widgets/article_card.dart'; // Import ArticleCard dari file terpisah

class ArticleListPage extends StatefulWidget {
  const ArticleListPage({super.key});

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  List<ArticlePage> articles = [];
  bool isLoading = true;
  String? error;
  String selectedTab = 'Public Articles';

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'https://southfeast-production.up.railway.app/forum/json/article/?filter=${selectedTab == 'Public Articles' ? 'public_articles' : 'your_articles'}',
      );

      if (!mounted) return;

      setState(() {
        articles = (response as List)
            .map((item) => ArticlePage.fromJson(item))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = 'Error fetching articles: $e';
        isLoading = false;
      });
    }
  }

  void _handleTabChange(String title) {
    final request = context.read<CookieRequest>();
    setState(() {
      selectedTab = title;
      isLoading = true;
      articles = []; // Pastikan artikel kosong saat tab berganti
      error = null;
    });

    // Jika tab "Your Articles" dipilih, periksa apakah user sudah login
    if (title == 'Your Articles' && !request.loggedIn) {
      // Jika belum login, kosongkan daftar artikel dan tampilkan error
      setState(() {
        isLoading = false;
        articles = [];
        error = 'Please log in to view your articles';
      });
    } else {
      // Jika sudah login atau tab "Public Articles", fetch artikel
      fetchArticles();
    }
  }

  Future<void> _handleAddArticle() async {
  final request = context.read<CookieRequest>();

  // Periksa apakah pengguna sudah login
  if (!request.loggedIn) {
    // Jika belum login, arahkan ke halaman login dan tunggu sampai selesai
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
    return; // Keluar dari fungsi setelah diarahkan ke halaman login
  }

  // Jika sudah login, arahkan ke halaman tambah artikel
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const ArticleFormPage(),
    ),
  ).then((_) {
    // Perbarui daftar artikel setelah form ditutup
    fetchArticles();
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Tabs
          Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => _handleTabChange('Public Articles'),
                  child: Text(
                    'Public Articles',
                    style: TextStyle(
                      color: selectedTab == 'Public Articles'
                          ? const Color(0xFF3B5FFF)
                          : Colors.grey,
                      fontSize: 16,
                      fontWeight: selectedTab == 'Public Articles'
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                TextButton(
                  onPressed: () => _handleTabChange('Your Articles'),
                  child: Text(
                    'Your Articles',
                    style: TextStyle(
                      color: selectedTab == 'Your Articles'
                          ? const Color(0xFF3B5FFF)
                          : Colors.grey,
                      fontSize: 16,
                      fontWeight: selectedTab == 'Your Articles'
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildArticleList(),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 65), // Naikkan posisi FAB
        child: FloatingActionButton(
          onPressed: _handleAddArticle,
          backgroundColor: Colors.black,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildArticleList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (articles.isEmpty && selectedTab == 'Your Articles') {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Please log in to view your articles',
              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (articles.isEmpty) {
      return const Center(
        child: Text(
          'No articles found',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return ArticleCard(
          title: article.fields.title,
          author: article.fields.author,
          createdAt: article.fields.createdAt,
          content: article.fields.content,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArticleDetailPage(article: article),
              ),
            ).then((_) => fetchArticles());
          },
        );
      },
    );
  }
}