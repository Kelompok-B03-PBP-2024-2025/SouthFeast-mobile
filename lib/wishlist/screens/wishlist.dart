import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:southfeast_mobile/wishlist/screens/widgets/edit_collection_page.dart';
import 'package:southfeast_mobile/wishlist/screens/wishlist_details.dart';
import '../models/wishlist_collection.dart';
import 'wishlist_details.dart'; 

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  late Future<List<WishlistCollection>> futureCollections;
  final String baseUrl = 'https://southfeast-production.up.railway.app/wishlist';
  // final String apiURL = 'https://southfeast-production.up.railway.app/wishlist/json/';
  // final String baseUrl = 'http://127.0.0.1:8000/wishlist';
  bool _isFirstLoad = true; // Flag to track initial load

  Future<List<WishlistCollection>> getCollections() async {
    final request = context.read<CookieRequest>();
    try {
      final url = '$baseUrl/flutter/collections/';
      final response = await request.get(url);

      if (response == null || response.isEmpty) {
        throw Exception('Empty response from server');
      }

      return List<WishlistCollection>.from(
          response.map((x) => WishlistCollection.fromJson(x)));
    } catch (e) {
      throw Exception('Failed to load collections: $e');
    }
  }

  Future<void> createCollection(String name, String description) async {
    final request = context.read<CookieRequest>();
    try {
      final url = '$baseUrl/flutter/collections/create/';

      final response = await request.post(
        url,
        jsonEncode({
          "name": name,
          "description": description,
        }),
      );

      if (response == null || response['error'] != null) {
        throw Exception(response?['error'] ?? 'Failed to create collection');
      }

      // Refresh collections on success
      setState(() {
        futureCollections = getCollections();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Collection "$name" created successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create collection: $e')),
      );
    }
  }

  void showAddCollectionDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Collection'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Collection Name',
                  hintText: 'Enter collection name',
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter description (optional)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final description = descriptionController.text.trim();

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Collection name is required')),
                  );
                  return;
                }

                Navigator.of(context).pop();
                await createCollection(name, description);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    futureCollections = getCollections();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  
    if (!_isFirstLoad) {
      // Trigger refresh when returning to the page
      setState(() {
        futureCollections = getCollections();
      });
    }
    _isFirstLoad = false; // Reset flag after initial load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Collections',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              showAddCollectionDialog();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<WishlistCollection>>(
        future: futureCollections,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(
              color: Colors.black, // Ganti warna loading indicator menjadi hitam
              strokeWidth: 2,
            ));
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        futureCollections = getCollections();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No collections yet. Create one!',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final collection = snapshot.data![index];
              return InkWell(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CollectionDetailPage(collectionId: collection.id),
                    ),
                  );

                  // Refresh collections if a change occurred in the detail page
                  if (result == true) {
                    setState(() {
                      futureCollections = getCollections();
                    });
                  }
                },
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          color: Colors.grey[200],
                          child: collection.items.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No items',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : GridView.count(
                                  crossAxisCount: 2,
                                  padding: const EdgeInsets.all(4), // Kurangi padding agar gambar lebih dekat
                                  mainAxisSpacing: 4, // Tambah spacing yang minimal
                                  crossAxisSpacing: 4,
                                  children: collection.items
                                      .take(4)
                                      .map((item) => ClipRRect( // Gunakan ClipRRect untuk rounded corners
                                        borderRadius: BorderRadius.circular(8),
                                        child: item.menuItem.image != null &&
                                                item.menuItem.image!.isNotEmpty
                                            ? Image.network(
                                                item.menuItem.image!,
                                                fit: BoxFit.cover, // Ubah ke cover agar gambar memenuhi area
                                                errorBuilder: (context, error, stackTrace) {
                                                  return const Icon(Icons.image_not_supported);
                                                },
                                              )
                                            : const Icon(
                                                Icons.image_not_supported,
                                                size: 50,
                                              ),
                                      ))
                                      .toList(),
                                )
                        )
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      collection.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Add edit button if not default collection
                                  if (!collection.isDefault)
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditCollectionPage(
                                              collection: collection,  // Sekarang menggunakan WishlistCollection
                                            ),
                                          ),
                                        );

                                        if (result == true) {
                                          setState(() {
                                            futureCollections = getCollections();
                                          });
                                        }
                                      },
                                    ),
                                ],
                              ),
                              Text(
                                '${collection.items.length} items',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
