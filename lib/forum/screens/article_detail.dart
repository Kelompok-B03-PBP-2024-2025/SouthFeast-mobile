import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'article_form.dart';
import '../models/article_page.dart';
import 'package:intl/intl.dart';

String fixUtf8(String text) {
  try {
    return utf8.decode(text.runes.toList());
  } catch (e) {
    return text;
  }
}

class ArticleDetailPage extends StatefulWidget {
  final ArticlePage article;
  final Function(String)? onArticleDeleted;

  const ArticleDetailPage({
    super.key,
    required this.article,
    this.onArticleDeleted,
  });

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  bool isUpdated = false; // Tambahkan ini di dalam _ArticleDetailPageState

  List<ArticlePage> articles = [];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<bool> isAuthenticated() async {
    final request = context.read<CookieRequest>();
    return request.loggedIn;
  }
  
  Future<void> fetchArticles() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        // 'https://southfeast-production.up.railway.app/forum/json/article/',
        'http://127.0.0.1:8000/forum/json/article/',
      );
      print('Response: $response'); // Debugging
    } catch (e) {
      print('Error: $e'); // Debugging
    }
  }

 Future<void> _editArticle() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ArticleFormPage(
        articleId: widget.article.pk,
        initialTitle: widget.article.fields.title,
        initialContent: widget.article.fields.content,
        // initialThumbnail: widget.article.fields.thumbnailFile,
      ),
    ),
  );

  // Jika artikel berhasil diperbarui, gunakan data langsung
  if (result != null && mounted) {
    setState(() {
      widget.article.fields.title = result['title'];
      widget.article.fields.content = result['content'];
      widget.article.fields.thumbnailFile = result['thumbnail'];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Article updated successfully!')),
    );

    // Kembalikan data perubahan ke halaman daftar
    Navigator.pop(context, {
      'pk': widget.article.pk,
      'title': result['title'],
      'content': result['content'],
      'thumbnail': result['thumbnail'],
    });
  }
 }

  Future<void> _postComment(CookieRequest request) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final requestData = {
        'article_id': widget.article.pk.toString(),
        'content': _commentController.text,
      };

      final response = await request.postJson(
        'https://southfeast-production.up.railway.app/forum/api/comment/create/',
        jsonEncode(requestData),
      );

      if (!mounted) return;

      if (response['success'] == true && response['comment'] != null) {
        final commentData = response['comment'];
        
        // Parse the date directly here
        DateTime parsedDate;
        try {
          parsedDate = DateTime.parse(commentData['created_at']);
        } catch (e) {
          // If parsing fails, use current time as fallback
          parsedDate = DateTime.now();
        }

        final newComment = Comment(
          id: commentData['id'],
          content: commentData['content'],
          author: commentData['author'],
          createdAt: parsedDate,
        );

        setState(() {
          widget.article.fields.comments.add(newComment);
          _commentController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment posted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to post comment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteComment(CookieRequest request, Comment comment) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Comment'),
      content: const Text('Are you sure you want to delete this comment?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    try {
      // Kirim data sebagai form-encoded (Map<String, String>)
      final response = await request.post(
        'http://127.0.0.1:8000/forum/api/comment/delete/${comment.id}/',
        {
          'action': 'delete', // Backend membutuhkan key 'action' dengan value 'delete'
        },
      );

      if (!mounted) return;

      if (response['success'] == true) {
        setState(() {
          widget.article.fields.comments.removeWhere((c) => c.id == comment.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to delete comment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

Future<void> _deleteArticle() async {
    final request = context.read<CookieRequest>();
    
    // Debug authentication status
    print("[DEBUG] Starting delete operation...");
    print("[DEBUG] Login status: ${request.loggedIn}");
    print("[DEBUG] Headers: ${request.headers}");
    
    // Check authentication first
    final isAuth = await isAuthenticated();
    print("[DEBUG] isAuthenticated result: $isAuth");

    if (!isAuth) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login first'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      print("[DEBUG] Attempting to delete article ${widget.article.pk}");
      
      final response = await request.postJson(
        'http://127.0.0.1:8000/forum/api/article/delete/${widget.article.pk}/',
        jsonEncode({
          '_method': 'DELETE',
        }),
      );

      print("[DEBUG] Delete response: $response");

      if (!mounted) return;

      if (response != null && response['success'] == true) {
        print("[DEBUG] Delete successful, popping with article ID");
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Article deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, {
          'id': widget.article.pk,
          'refresh': true,
        });
      } else {
        print("[DEBUG] Delete failed: ${response?['message']}");
        
        if (response?['message']?.toLowerCase() == 'unauthorized') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are not authorized to delete this article'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response?['message'] ?? 'Failed to delete article'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print("[DEBUG] Error during deletion: $e");
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


 @override
  Widget build(BuildContext context) {
    final fields = widget.article.fields;
  print("[DEBUG] Article author: ${fields.author}");
  print("[DEBUG] Current user: olena"); // atau user yang sedang login
  print("[DEBUG] canEdit value: ${fields.canEdit}");
    final comments = fields.comments;
    final request = context.watch<CookieRequest>();

    return Scaffold(
      key: ValueKey(fields.title + fields.content),
      appBar: AppBar(
        title: const Text('Article Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, isUpdated);
          },
        ),
        actions: [
          if (widget.article.fields.canEdit) ...[  // Only show edit/delete if user can edit
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editArticle,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteArticle,
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail Image Section
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        fields.thumbnailFile != null && fields.thumbnailFile!.isNotEmpty
                            ? (fields.thumbnailFile!.startsWith('http')
                                ? fields.thumbnailFile!
                                : 'https://southfeast-production.up.railway.app${fields.thumbnailFile}')
                                : 'https://southfeast-production.up.railway.app/static/image/default-thumbnail.jpg', // URL Default
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Jika gagal memuat gambar
                          return Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 50),
                            ),
                          );
                        },
                      ),
                    ),
                    // Article Title
                    Text(
                      fixUtf8(fields.title),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Author and Date
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          fixUtf8(fields.author),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Article Content
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        fixUtf8(fields.content),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Comments Section
                    Row(
                      children: [
                        const Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${comments.length})',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Comments List
                    if (widget.article.fields.comments.isEmpty)
                      const Text('No comments yet')
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.article.fields.comments.length,
                        itemBuilder: (context, index) {
                          final comment = widget.article.fields.comments[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.blue[100],
                                      child: Text(
                                        fixUtf8(comment.author)[0].toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.blue[900],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            fixUtf8(comment.author),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            formatDateTime(comment.createdAt), // Gunakan waktu yang sesuai dari data
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Tambahkan tombol delete jika user adalah penulis komentar
                                    if (widget.article.fields.canEdit)
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 20),
                                        color: const Color.fromARGB(255, 23, 23, 23),
                                        onPressed: () => _deleteComment(request, comment),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  fixUtf8(comment.content),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Add Comment Form
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Write a comment...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a comment';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: const Color.fromARGB(255, 0, 0, 0),
                    onPressed: () {
                      if (!request.loggedIn) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please login first')),
                        );
                        Navigator.pushReplacementNamed(context, '/login');
                        return;
                      }
                      _postComment(request);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String formatDateTime(dynamic date) {
    try {
      DateTime dateTime;
      if (date is DateTime) {
        dateTime = date;
      } else if (date is String) {
        dateTime = DateTime.parse(date);
      } else {
        throw const FormatException('Invalid date format');
      }
      
      final DateFormat formatter = DateFormat('dd MMM, yyyy');
      return formatter.format(dateTime);
    } catch (e) {
      // Return a fallback format or the original string if parsing fails
      return date.toString();
    }
  }

  String formatServerDate(String date) {
    try {
      final DateFormat inputFormat = DateFormat('dd MMM, yyyy'); // Sesuaikan dengan format server
      final DateTime parsedDate = inputFormat.parse(date);
      return formatDateTime(parsedDate);
    } catch (e) {
      return date; // Jika parsing gagal, kembalikan nilai asli
    }
  }
}