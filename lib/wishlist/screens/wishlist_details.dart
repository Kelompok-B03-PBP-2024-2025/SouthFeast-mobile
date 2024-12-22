import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:southfeast_mobile/dashboard/models/product/result.dart';
import 'package:southfeast_mobile/product/screens/detail_makanan.dart'; 

class CollectionDetailPage extends StatefulWidget {
  final int collectionId;

  const CollectionDetailPage({super.key, required this.collectionId});

  @override
  State<CollectionDetailPage> createState() => _CollectionDetailPageState();
}

class _CollectionDetailPageState extends State<CollectionDetailPage> {
  late Future<Map<String, dynamic>> futureCollection;
  bool isEdited = false; // Track if any changes were made

  @override
  void initState() {
    super.initState();
    futureCollection = fetchCollectionDetail(widget.collectionId);
  }

  Future<Map<String, dynamic>> fetchCollectionDetail(int id) async {
  final request = context.read<CookieRequest>();
  
  try {
    // Jika id = 0, ini adalah My Wishlist yang akan menampilkan semua item
    if (id == 0) {
      // Fetch semua collection terlebih dahulu
      final allCollectionsUrl = 'https://southfeast-production.up.railway.app/wishlist/flutter/collections';
      final allCollectionsResponse = await request.get(allCollectionsUrl);

      if (allCollectionsResponse == null) {
        throw Exception('Failed to fetch collections');
      }

      // Kumpulkan semua items dari semua collection
      List<dynamic> allItems = [];
      for (var collection in allCollectionsResponse) {
        if (collection['items'] != null) {
          allItems.addAll(collection['items']);
        }
      }

      // Return format yang sama tapi dengan semua items
      return {
        'id': 0,
        'name': 'My Wishlist',
        'description': 'All your wishlisted items',
        'is_default': true,
        'items': allItems,
      };
    }

    // Untuk collection lain, gunakan endpoint normal
    final url = 'https://southfeast-production.up.railway.app/wishlist/flutter/collections/$id/';
    final response = await request.get(url);

    if (response == null) {
      throw Exception('Failed to load collection detail');
    }

    return response;
  } catch (e) {
    throw Exception('Failed to load collection detail: $e');
  }
}

  Future<void> removeItemFromCollection(int itemId) async {
    try {
      final request = context.read<CookieRequest>();
      // final url = 'http://127.0.0.1:8000/wishlist/flutter/wishlist/$itemId/remove/';
      final url = 'https://southfeast-production.up.railway.app/wishlist/flutter/wishlist/$itemId/remove/';
      final response = await request.post(url, {});

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to remove item');
      }

      // Refresh the collection details
      setState(() {
        futureCollection = fetchCollectionDetail(widget.collectionId);
        isEdited = true; 
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item removed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove item: $e')),
      );
    }
  }

  Future<void> moveItemToCollection(int itemId, int targetCollectionId) async {
    try {
      final request = context.read<CookieRequest>();
      // final url =
      //     'http://127.0.0.1:8000/wishlist/flutter/item/$itemId/move/$targetCollectionId/';
      final url =
          'https://southfeast-production.up.railway.app/wishlist/flutter/item/$itemId/move/$targetCollectionId/';
      final response = await request.post(url, {});

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to move item');
      }

      // Refresh the collection details
      setState(() {
        futureCollection = fetchCollectionDetail(widget.collectionId);
        isEdited = true; // Mark changes
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item moved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to move item: $e')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchAvailableCollections() async {
    final request = context.read<CookieRequest>();
    // final url = 'http://127.0.0.1:8000/wishlist/flutter/collections';
    final url = 'https://southfeast-production.up.railway.app/wishlist/flutter/collections';
    final response = await request.get(url);

    if (response == null) {
      throw Exception('Failed to fetch collections');
    }

    return (response as List<dynamic>)
        .map((collection) => {
              'id': collection['id'],
              'name': collection['name'],
              'is_default': collection['is_default'],
            })
        .where((collection) => collection['id'] != widget.collectionId) // Exclude current collection
        .toList();
  }

  // === EDIT a collection ===
  Future<void> editCollection(int id, String newName, String newDescription) async {
    try {
      final request = context.read<CookieRequest>();
      // final url = 'http://127.0.0.1:8000/wishlist/flutter/collections/$id/edit/';
      final url = 'https://southfeast-production.up.railway.app/wishlist/flutter/collections/$id/edit/';

      // Encode the data as JSON
      final response = await request.post(
        url,
        jsonEncode({
          "name": newName,
          "description": newDescription,
        }),
      );

      if (response['error'] != null) {
        throw Exception(response['error']);
      }

      // Refresh this page
      setState(() {
        futureCollection = fetchCollectionDetail(id);
        isEdited = true;  // Mark as edited
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Collection "$newName" updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to edit: $e')),
      );
    }
  }

  void confirmDeleteCollection(int collectionId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this collection?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog
            style: TextButton.styleFrom(
              foregroundColor: Colors.black, // Warna teks hitam
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, // Background hitam
              foregroundColor: Colors.white, // Teks putih
            ),
            onPressed: () async {
              Navigator.pop(context); // Close confirm dialog
              await deleteCollection(collectionId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void showEditCollectionDialog(String currentName, String currentDescription) {
    final nameController = TextEditingController(text: currentName);
    final descController = TextEditingController(text: currentDescription);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Collection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Collection Name'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog
            style: TextButton.styleFrom(
              foregroundColor: Colors.black, // Warna teks hitam
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, // Background hitam
              foregroundColor: Colors.white, // Teks putih
            ),
            onPressed: () async {
              final newName = nameController.text.trim();
              final newDesc = descController.text.trim();

              if (newName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name cannot be empty')),
                );
                return;
              }

              Navigator.pop(context); // Close the dialog
              await editCollection(widget.collectionId, newName, newDesc);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // === DELETE a collection ===
  Future<void> deleteCollection(int id) async {
    try {
      final request = context.read<CookieRequest>();
      // final url = 'http://127.0.0.1:8000/wishlist/flutter/collections/$id/delete/';
      final url = 'https://southfeast-production.up.railway.app/wishlist/flutter/collections/$id/delete/';
      final response = await request.post(url, {}); // or request.delete, etc.

      if (response['error'] != null) {
        throw Exception(response['error']);
      }

      // Immediately go back to wishlist page and pass 'true' so it knows to refresh
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collection deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }

  void showMoveDialog(int itemId, String itemName) {
    showDialog(
      context: context,
      builder: (_) => FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAvailableCollections(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: 
            CircularProgressIndicator(
              color: Colors.black, // Ganti warna loading indicator menjadi hitam
              strokeWidth: 2,
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final collections = snapshot.data ?? [];

          return AlertDialog(
            title: Text('Move "$itemName"'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var collection in collections)
                  ListTile(
                    title: Text(collection['name']),
                    onTap: () async {
                      Navigator.pop(context); // Close the dialog
                      await moveItemToCollection(itemId, collection['id']);
                    },
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Close dialog
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black, // Warna teks hitam
                ),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Add this method to convert MenuItem to Result
  Result _convertMenuItemToResult(Map<String, dynamic> menuItem) {
    return Result(
      id: menuItem['id'],
      name: menuItem['name'],
      price: menuItem['price'],
      image: menuItem['image'],
      // Set other fields with default values or data from your API
      category: '',  // Set default or get from API
      kecamatan: '', // Set default or get from API
      restaurantName: '', // Set default or get from API
      description: '', // Set default or get from API
      location: '', // Set default or get from API
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, isEdited); 
        return false;
      },
      child: Scaffold(
        body: FutureBuilder<Map<String, dynamic>>(
          future: futureCollection,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: 
              CircularProgressIndicator(
                color: Colors.black, // Ganti warna loading indicator menjadi hitam
                strokeWidth: 2,
              ));
            } else if (snapshot.hasError) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Collection Detail'),
                ),
                body: Center(
                  child: Text('Error: ${snapshot.error}'),
                ),
              );
            } else if (!snapshot.hasData) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Collection Detail'),
                ),
                body: const Center(
                  child: Text('No data found.'),
                ),
              );
            } 

            final data = snapshot.data!;
            final isDefault = data['is_default'] ?? false;
            final collectionName = data['name'] ?? '';
            final collectionDescription = data['description'] ?? '';
            final items = data['items'] as List<dynamic>? ?? [];

            return Scaffold(
              appBar: AppBar(
                title: Text(collectionName),
                actions: [
                  // Only show edit and delete buttons if not default collection
                  if (!isDefault) ...[  // Using spread operator with conditional
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        showEditCollectionDialog(data['name'], data['description']);
                      },
                      tooltip: 'Edit Collection',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        confirmDeleteCollection(widget.collectionId);
                      },
                      tooltip: 'Delete Collection',
                    ),
                  ],
                ],
              ),
              body: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Text(
                    collectionName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    collectionDescription,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Items in this collection:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (items.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.list_alt,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No items in this collection',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  for (var item in items) ...[
                    Card(
                      child: ListTile(
                        leading: (item['menu_item']['image'] != null &&
                                (item['menu_item']['image'] as String).isNotEmpty)
                            ? Image.network(
                                item['menu_item']['image'],
                                width: 50,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error);
                                },
                              )
                            : const Icon(Icons.image_not_supported),
                        title: Text(item['menu_item']['name'] ?? 'No name'),
                        subtitle: Text('Price: ${item['menu_item']['price']}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'remove') {
                              await removeItemFromCollection(item['id']);
                            } else if (value == 'move') {
                              showMoveDialog(item['id'], item['menu_item']['name']);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'move',
                              child: Row(
                                children: [
                                  Icon(Icons.drive_file_move_outlined),
                                  SizedBox(width: 8),
                                  Text('Move'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'remove',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline),
                                  SizedBox(width: 8),
                                  Text('Remove'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          // Convert menu item to Result and navigate
                          final result = _convertMenuItemToResult(item['menu_item']);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailMakanan(
                                result: result,
                                isAuthenticated: true,
                                isStaff: false,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}