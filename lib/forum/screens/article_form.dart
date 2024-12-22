// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:pbp_django_auth/pbp_django_auth.dart';
// import '../models/article_page.dart';

// class ArticleFormPage extends StatefulWidget {
//   final ArticlePage? article; // Data artikel jika dalam mode edit

//   const ArticleFormPage({super.key, this.article});

//   @override
//   State<ArticleFormPage> createState() => _ArticleFormPageState();
// }

// class _ArticleFormPageState extends State<ArticleFormPage> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _titleController;
//   late TextEditingController _contentController;
//   late TextEditingController _thumbnailController;

//   @override
//   void initState() {
//     super.initState();
//     // Inisialisasi controller dengan data awal
//     _titleController = TextEditingController(text: widget.article?.fields.title ?? '');
//     _contentController = TextEditingController(text: widget.article?.fields.content ?? '');
//     _thumbnailController = TextEditingController(text: widget.article?.fields.thumbnailFile ?? '');
//   }

//   @override
//   void dispose() {
//     // Dispose controller untuk menghindari memory leak
//     _titleController.dispose();
//     _contentController.dispose();
//     _thumbnailController.dispose();
//     super.dispose();
//   }

//   Future<void> _submitArticle(CookieRequest request) async {
//     // Validasi form sebelum submit
//     if (!_formKey.currentState!.validate()) return;

//     // Data yang akan dikirim ke backend
//     final requestData = {
//       'title': _titleController.text,
//       'content': _contentController.text,
//       'thumbnail_file': _thumbnailController.text,
//     };

//     // URL API untuk Create atau Edit
//     final String url = widget.article == null
//         ? 'https://southfeast-production.up.railway.app/forum/api/article/create/'
//         : 'https://southfeast-production.up.railway.app/forum/api/article/edit/${widget.article!.pk}/';

//     try {
//       // Kirim request ke server
//       final response = await request.postJson(url, jsonEncode(requestData));

//       if (!mounted) return;

//       if (response['success'] == true) {
//         // Navigasi kembali dengan data yang diubah
//         Navigator.pop(context, true);
//         // Navigator.pop(context, {
//         //   'title': _titleController.text,
//         //   'content': _contentController.text,
//         //   'thumbnailFile': _thumbnailController.text,
//         // });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(response['message'] ?? 'Failed to save article')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final request = context.watch<CookieRequest>();

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.article == null ? 'Create New Article' : 'Edit Article'),
//       ),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Field untuk Title
//               TextFormField(
//                 controller: _titleController,
//                 decoration: InputDecoration(
//                   labelText: 'Title',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) return 'Please enter a title';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),

//               // Field untuk Thumbnail URL
//               TextFormField(
//                 controller: _thumbnailController,
//                 decoration: InputDecoration(
//                   labelText: 'Thumbnail URL',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value != null && value.isNotEmpty && !Uri.tryParse(value)!.isAbsolute) {
//                     return 'Please enter a valid URL';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),

//               // Field untuk Content
//               TextFormField(
//                 controller: _contentController,
//                 decoration: InputDecoration(
//                   labelText: 'Content',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 maxLines: 5,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) return 'Please enter content';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 24),

//               // Tombol Submit
//               ElevatedButton(
//                 onPressed: () => _submitArticle(request),
//                 child: Text(widget.article == null ? 'Submit' : 'Save Changes'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:http_parser/http_parser.dart';
// import 'package:pbp_django_auth/pbp_django_auth.dart';

// class ArticleFormPage extends StatefulWidget {
//   final String? articleId;
//   final String? initialTitle;
//   final String? initialContent;
//   final String? initialThumbnail;

//   const ArticleFormPage({
//     super.key,
//     this.articleId,
//     this.initialTitle,
//     this.initialContent,
//     this.initialThumbnail,
//   });

//   @override
//   State<ArticleFormPage> createState() => _ArticleFormPageState();
// }

// class _ArticleFormPageState extends State<ArticleFormPage> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _titleController;
//   late TextEditingController _contentController;
//   File? _imageFile;
//   final _picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     _titleController = TextEditingController(text: widget.initialTitle ?? '');
//     _contentController = TextEditingController(text: widget.initialContent ?? '');
//   }

//   Future<bool> isAuthenticated(BuildContext context) async {
//     final request = context.read<CookieRequest>();

//     // Cek apakah widget masih mounted
//     if (!mounted) return false;

//     return request.loggedIn;
//   }

//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//       });
//     }
//   }

//   Future<void> _submitArticle(CookieRequest request) async {
//   if (!_formKey.currentState!.validate()) return;

//   try {
//     final url = widget.articleId == null
//         ? 'https://southfeast-production.up.railway.app/forum/api/article/create/'
//         : 'https://southfeast-production.up.railway.app/forum/api/article/edit/${widget.articleId}/';

//     // Gunakan request.post langsung untuk mengirim data
//     final response = await request.post(
//       url,
//       {
//         'title': _titleController.text,
//         'content': _contentController.text,
//       },
//     );

//     if (!mounted) return;

//     if (response['success'] == true) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Article saved successfully')),
//       );
//       Navigator.pop(context, true);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to save article: ${response['message']}')),
//       );
//     }
//   } catch (e) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Error: $e')),
//     );
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.articleId == null ? 'Create Article' : 'Edit Article'),
//       ),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Title field
//               TextFormField(
//                 controller: _titleController,
//                 decoration: const InputDecoration(
//                   labelText: 'Title',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a title';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               // Content field
//               TextFormField(
//                 controller: _contentController,
//                 decoration: const InputDecoration(
//                   labelText: 'Content',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 5,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter content';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               // Image picker
//               ElevatedButton.icon(
//                 onPressed: _pickImage,
//                 icon: const Icon(Icons.image),
//                 label: const Text('Choose Image'),
//               ),
//               if (_imageFile != null) ...[
//                 const SizedBox(height: 16),
//                 Image.file(
//                   _imageFile!,
//                   height: 200,
//                   fit: BoxFit.cover,
//                 ),
//               ],
//               const SizedBox(height: 24),
//               // Submit button
//               // Tombol Submit
//               ElevatedButton(
//                 onPressed: () async {
//                   final request = context.read<CookieRequest>();
//                   await _submitArticle(request); // Panggil fungsi asinkron
//                 },
//                 child: Text(
//                   widget.articleId == null ? 'Create Article' : 'Save Changes',
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _contentController.dispose();
//     super.dispose();
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:pbp_django_auth/pbp_django_auth.dart';

// class ArticleFormPage extends StatefulWidget {
//   final String? articleId;
//   final String? initialTitle;
//   final String? initialContent;
//   final String? initialThumbnail;

//   const ArticleFormPage({
//     super.key,
//     this.articleId,
//     this.initialTitle,
//     this.initialContent,
//     this.initialThumbnail,
//   });

//   @override
//   State<ArticleFormPage> createState() => _ArticleFormPageState();
// }

// class _ArticleFormPageState extends State<ArticleFormPage> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _titleController;
//   late TextEditingController _contentController;
//   late TextEditingController _thumbnailController;

//   @override
//   void initState() {
//     super.initState();
//     _titleController = TextEditingController(text: widget.initialTitle ?? '');
//     _contentController = TextEditingController(text: widget.initialContent ?? '');
//     _thumbnailController = TextEditingController(text: widget.initialThumbnail ?? '');
//   }

//   Future<void> _submitArticle(CookieRequest request) async {
//     if (!_formKey.currentState!.validate()) return;

//     try {
//       final url = widget.articleId == null
//           ? 'https://southfeast-production.up.railway.app/forum/api/article/create/'
//           : 'https://southfeast-production.up.railway.app/forum/api/article/edit/${widget.articleId}/';

//       // Gunakan URL default jika thumbnail kosong
//       final thumbnail = _thumbnailController.text.isNotEmpty
//           ? _thumbnailController.text
//           : 'https://southfeast-production.up.railway.app/static/image/default-thumbnail.jpg';

//       // Kirim data ke backend
//       final response = await request.post(
//         url,
//         {
//           'title': _titleController.text,
//           'content': _contentController.text,
//           'thumbnail': thumbnail, // Thumbnail akan selalu memiliki nilai
//         },
//       );

//       if (!mounted) return;

//       if (response['success'] == true) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Article saved successfully')),
//         );
//         Navigator.pop(context, {
//           'title': _titleController.text,
//           'content': _contentController.text,
//           'thumbnail': _thumbnailController.text,
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to save article: ${response['message']}')),
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.articleId == null ? 'Create Article' : 'Edit Article'),
//       ),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Title field
//               TextFormField(
//                 controller: _titleController,
//                 decoration: const InputDecoration(
//                   labelText: 'Title',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a title';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               // Content field
//               TextFormField(
//                 controller: _contentController,
//                 decoration: const InputDecoration(
//                   labelText: 'Content',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 5,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter content';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               // Thumbnail URL field
//               TextFormField(
//                 controller: _thumbnailController,
//                 decoration: const InputDecoration(
//                   labelText: 'Thumbnail URL (optional)',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value != null && value.isNotEmpty && !Uri.parse(value).isAbsolute) {
//                     return 'Please enter a valid URL';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               // Display Thumbnail
//               Image.network(
//                 _thumbnailController.text.isNotEmpty
//                     ? _thumbnailController.text
//                     : 'https://southfeast-production.up.railway.app/static/image/default-thumbnail.jpg',
//                 height: 200,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) => const Text('Failed to load image'),
//               ),
//               const SizedBox(height: 24),
//               // Submit button
//               ElevatedButton(
//                 onPressed: () async {
//                   final request = context.read<CookieRequest>();
//                   await _submitArticle(request); // Panggil fungsi asinkron
//                 },
//                 child: Text(
//                   widget.articleId == null ? 'Create Article' : 'Save Changes',
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _contentController.dispose();
//     _thumbnailController.dispose();
//     super.dispose();
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class ArticleFormPage extends StatefulWidget {
  final String? articleId;
  final String? initialTitle;
  final String? initialContent;

  const ArticleFormPage({
    super.key,
    this.articleId,
    this.initialTitle,
    this.initialContent,
  });

  @override
  State<ArticleFormPage> createState() => _ArticleFormPageState();
}

class _ArticleFormPageState extends State<ArticleFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isSubmitting = false; // Untuk mencegah submit ganda

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _contentController = TextEditingController(text: widget.initialContent ?? '');
  }

  Future<void> _submitArticle(CookieRequest request) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final url = widget.articleId == null
          ? 'https://southfeast-production.up.railway.app/forum/api/article/create/'
          : 'https://southfeast-production.up.railway.app/forum/api/article/edit/${widget.articleId}/';

      final csrfToken = request.cookies['csrftoken'] ?? '';
      request.headers['X-CSRFToken'] = csrfToken.toString();

      final response = await request.post(
        url,
        {
          'title': _titleController.text,
          'content': _contentController.text,
        },
      );

      if (!mounted) return;

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Article saved successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save article: ${response['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
        title: Text(widget.articleId == null ? 'Create New Article' : 'Edit Article'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Tombol kembali
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Content Field
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        final request = context.read<CookieRequest>();
                        await _submitArticle(request);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isSubmitting
                      ? 'Submitting...'
                      : (widget.articleId == null ? 'Create Article' : 'Save Changes'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
