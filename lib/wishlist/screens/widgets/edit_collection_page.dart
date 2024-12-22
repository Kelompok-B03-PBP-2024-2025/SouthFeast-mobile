import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:southfeast_mobile/wishlist/models/wishlist_collection.dart';

class EditCollectionPage extends StatefulWidget {
  final WishlistCollection collection;

  const EditCollectionPage({super.key, required this.collection});

  @override
  _EditCollectionPageState createState() => _EditCollectionPageState();
}

class _EditCollectionPageState extends State<EditCollectionPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  final String baseUrl = 'https://southfeast-production.up.railway.app/wishlist';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.collection.name);
    _descriptionController = TextEditingController(text: widget.collection.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateCollection() async {
    final request = context.read<CookieRequest>();
    
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collection name cannot be empty')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Perhatikan format URL dan body request
      final response = await request.post(
        '$baseUrl/flutter/collections/${widget.collection.id}/edit/',
        jsonEncode({
          'name': name,
          'description': _descriptionController.text.trim(),
        }),
      );

      if (context.mounted) {
        if (response != null) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Collection "$name" updated successfully')),
          );
        } else {
          throw Exception('Failed to update collection');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update collection: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteCollection() async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => 
      AlertDialog(
        title: const Text('Delete Collection'),
        content: const Text('Are you sure you want to delete this collection? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black, // Tambahkan ini untuk warna teks hitam
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white, // Tambahkan ini untuk warna teks hitam
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      setState(() => _isLoading = true);

      try {
        final request = context.read<CookieRequest>();
        final response = await request.post(
          '$baseUrl/flutter/collections/${widget.collection.id}/delete/',
          {},  // Empty body karena kita hanya mengirim request delete
        );

        if (context.mounted) {
          if (response != null) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Collection "${widget.collection.name}" deleted successfully')),
            );
          } else {
            throw Exception('Failed to delete collection');
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete collection: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Collection'),
        centerTitle: true,
        actions: [
          if (!widget.collection.isDefault)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteCollection,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Collection Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: 
                    ElevatedButton(
                      onPressed: _isLoading ? null : _updateCollection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white, // Tambahkan ini untuk warna teks putih
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: 
                              CircularProgressIndicator(
                                color: Colors.black, 
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}