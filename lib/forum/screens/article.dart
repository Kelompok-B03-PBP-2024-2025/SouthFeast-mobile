// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:pbp_django_auth/pbp_django_auth.dart';
// import '../models/article_page.dart';
// import 'article_detail.dart';
// import 'article_form.dart';

// class ArticleListPage extends StatefulWidget {
//   const ArticleListPage({super.key});

//   @override
//   State<ArticleListPage> createState() => _ArticleListPageState();
// }

// class _ArticleListPageState extends State<ArticleListPage> {
//   List<ArticlePage> articles = [];

  
//   bool isLoading = true;
//   String? error;
//   String selectedTab = 'Public Articles';

//   @override
//   void initState() {
//     super.initState();
//     fetchArticles();
//   }

//  Future<void> fetchArticles() async {
//   if (!mounted) return;

//   setState(() {
//     isLoading = true;
//     error = null;
//   });

//   final request = context.read<CookieRequest>();
//   try {
//     final String filterParam =
//         selectedTab == 'Public Articles' ? 'public_articles' : 'your_articles';

//     // Tambahkan timestamp untuk mencegah cache
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final response = await request.get(
//       'http://127.0.0.1:8000/forum/json/article/?filter=$filterParam&t=$timestamp',
//     );

//     print('[DEBUG] Fetched Articles Response: $response');

//     if (!mounted) return;

//     setState(() {
//       if (response is List) {
//         articles = response.map((item) => ArticlePage.fromJson(item)).toList();
//         print('[DEBUG] Jumlah artikel setelah fetch: ${articles.length}');
//       } else {
//         articles = [];
//         print('[DEBUG] Response bukan List, articles di-set kosong');
//       }
//       isLoading = false;
//     });
//   } catch (e) {
//     print('[DEBUG] Error fetching articles: $e');
//     if (!mounted) return;
//     setState(() {
//       error = 'Error fetching articles: $e';
//       isLoading = false;
//       articles = [];
//     });
//   }
// }

//   void _handleTabChange(String title) {
//     final request = context.read<CookieRequest>();
//     if (title == 'Your Articles' && !request.loggedIn) {
//       Navigator.of(context).pushReplacementNamed('/login');
//       return;
//     }

//     setState(() {
//       selectedTab = title;
//       isLoading = true;
//     });

//     fetchArticles();
//   }

//   Future<void> _handleAddArticle() async {
//     final request = context.read<CookieRequest>();
//     if (!request.loggedIn) {
//       Navigator.of(context).pushReplacementNamed('/login');
//       return;
//     }

//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const ArticleFormPage(),
//       ),
//     );

//     if (result != null && result is bool && result == true) {
//       setState(() {
//         isLoading = true;
//       });
//       await fetchArticles();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 TextButton(
//                   onPressed: () => _handleTabChange('Public Articles'),
//                   child: Text(
//                     'Public Articles',
//                     style: TextStyle(
//                       color: selectedTab == 'Public Articles'
//                           ? const Color(0xFF3B5FFF)
//                           : Colors.grey,
//                       fontSize: 16,
//                       fontWeight: selectedTab == 'Public Articles'
//                           ? FontWeight.w600
//                           : FontWeight.normal,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 24),
//                 TextButton(
//                   onPressed: () => _handleTabChange('Your Articles'),
//                   child: Text(
//                     'Your Articles',
//                     style: TextStyle(
//                       color: selectedTab == 'Your Articles'
//                           ? const Color(0xFF3B5FFF)
//                           : Colors.grey,
//                       fontSize: 16,
//                       fontWeight: selectedTab == 'Your Articles'
//                           ? FontWeight.w600
//                           : FontWeight.normal,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: _buildMainContent(),
//           ),
//         ],
//       ),
//       floatingActionButton: Padding(
//       padding: const EdgeInsets.only(bottom: 70.0),
//       child: FloatingActionButton(
//         onPressed: _handleAddArticle,
//         backgroundColor: Colors.black,
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     ),
//     floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
//     );
//   }

//   Widget _buildMainContent() {
//     if (isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (error != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Error: $error'),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   isLoading = true;
//                   error = null;
//                 });
//                 fetchArticles();
//               },
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     return _buildArticleList();
//   }

//   Widget _buildArticleList() {
//     if (articles.isEmpty) {
//       return const Center(
//         child: Text('No articles found'),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: fetchArticles,
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: articles.length,
//         itemBuilder: (context, index) {
//           final article = articles[index];
//           return ArticleCard(
//             title: article.fields.title,
//             author: article.fields.author,
//             createdAt: article.fields.createdAt.toIso8601String(),
//             content: article.fields.content,
//             thumbnailImg: article.fields.thumbnailFile?.isNotEmpty == true
//               ? article.fields.thumbnailFile!
//               : 'https://southfeast-production.up.railway.app/static/image/default-thumbnail.jpg',
//             onTap: () async {
//               final result = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => ArticleDetailPage(article: article),
//                 ),
//               );

//               if (result != null && mounted) {
//                 if (result is Map<String, dynamic>) {
//                   if (result['refresh'] == true) {
//                     // Kalau ada flag refresh, fetch ulang semua data
//                     await fetchArticles();
//                   } else {
//                     // Handle update artikel
//                     final index = articles.indexWhere((a) => a.pk == result['pk']);
//                     if (index != -1) {
//                       setState(() {
//                         articles[index].fields.title = result['title'];
//                         articles[index].fields.content = result['content'];
//                         articles[index].fields.thumbnailFile = result['thumbnail'];
//                       });
//                     }
//                   }
//                 }
//               }
//             },
//             // onTap: () async {
//             //   final result = await Navigator.push(
//             //     context,
//             //     MaterialPageRoute(
//             //       builder: (context) => ArticleDetailPage(article: article),
//             //     ),
//             //   );

//             //   if (result is String) {
//             //     // Jika artikel dihapus, hapus dari daftar artikel
//             //     setState(() {
//             //       articles!.removeWhere((a) => a.pk == result);
//             //     });
//             //   }
//             // },
//           );
//         },
//       ),
//     );
//   }
// }

// class ArticleCard extends StatelessWidget {
//   final String title;
//   final String author;
//   final String createdAt;
//   final String thumbnailImg;
//   final String content;
//   final VoidCallback onTap;
//   final VoidCallback? onDelete;

//   const ArticleCard({
//     super.key,
//     required this.title,
//     required this.author,
//     required this.createdAt,
//     required this.thumbnailImg,
//     this.content = '',
//     required this.onTap,
//     this.onDelete,
//   });

//   String formatDate(String isoString) {
//     final dateTime = DateTime.parse(isoString);
//     return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ClipRRect(
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//               child: Image.network(
//                 thumbnailImg.isNotEmpty
//                     ? thumbnailImg
//                     : 'https://southfeast-production.up.railway.app/static/image/default-thumbnail.jpg',
//                 height: 200,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) {
//                   return const SizedBox(
//                     height: 200,
//                     child: Center(
//                       child: Icon(Icons.broken_image, size: 50), // Fallback jika gagal load
//                     ),
//                   );
//                 },
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: Theme.of(context).textTheme.titleLarge!.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'by $author | ${formatDate(createdAt)}',
//                     style: Theme.of(context).textTheme.bodySmall,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     content,
//                     style: Theme.of(context).textTheme.bodyMedium,
//                     maxLines: 3,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/article_page.dart';
import 'article_detail.dart';
import 'article_form.dart';
import 'package:southfeast_mobile/authentication/screens/login.dart';

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
    setState(() {
      selectedTab = title;
      isLoading = true;
    });

    fetchArticles();
  }

  Future<void> _handleAddArticle() async {
    final request = context.read<CookieRequest>();
    if (!request.loggedIn) {
      // Jika belum login, arahkan ke halaman login
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ArticleFormPage(),
      ),
    ).then((_) => fetchArticles());
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

class ArticleCard extends StatelessWidget {
  final String title;
  final String author;
  final DateTime createdAt;
  final String content;
  final VoidCallback onTap;

  const ArticleCard({
    super.key,
    required this.title,
    required this.author,
    required this.createdAt,
    required this.content,
    required this.onTap,
  });

  String formatDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime); // Format tanggal
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'by $author | ${formatDate(createdAt)}', // Format tanggal
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
