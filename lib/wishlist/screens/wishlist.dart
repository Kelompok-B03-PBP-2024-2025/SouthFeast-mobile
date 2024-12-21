// lib/screens/wishlist.dart
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/wishlist_collection.dart';
import 'wishlist_detail.dart'; 

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  Future<WishlistCollection>? futureCollections;
  final String baseUrl = 'https://southfeast-production.up.railway.app/wishlist';
  final String apiURL = 'https://southfeast-production.up.railway.app/wishlist/json/';
  // final String baseUrl = 'http://127.0.0.1:8000/wishlist';
  // final String apiURL = 'http://127.0.0.1:8000/wishlist/json/';

  @override
  void initState() {
    super.initState();
    // Check authentication and load collections if authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await isAuthenticated()) {
        loadCollections();
      }
    });
  }

  Future<bool> isAuthenticated() async {
    final request = context.read<CookieRequest>();
    // Check if user has valid session/cookie
    return request.loggedIn;
  }

  Future<WishlistCollection> getCollections() async {
    final request = context.read<CookieRequest>();
    try {
      final url = apiURL;
      final response = await request.get(url);

      if (response == null) {
        throw Exception('Response is null');
      }

      // Tambahkan print untuk debug
      print('Received collections: $response');

      // Gunakan fromJson dari model baru
      return WishlistCollection.fromJson(response);
    } catch (e, stackTrace) {
      print('Error type: ${e.runtimeType}');
      print('Error details: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to load collections: $e');
    }
  }

  void loadCollections() {
    setState(() {
      futureCollections = getCollections();
    });
  }

  Future<void> createCollection() async {
    final request = context.read<CookieRequest>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Collection'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Collection Name',
                    labelText: 'Name',
                  ),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Collection Description (Optional)',
                    labelText: 'Description',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Create'),
              onPressed: () async {
                final String name = nameController.text.trim();
                final String description = descriptionController.text.trim();

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Collection name is required')),
                  );
                  return;
                }

                try {
                  final response = await request.post(
                    '$baseUrl/flutter/collections/create/',  // Gunakan baseUrl yang sudah didefinisikan
                    {
                      'name': name,
                      'description': description,
                    },
                  );

                  if (response != null) {
                    // Reload collections after creating
                    loadCollections();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Collection "$name" created successfully')),
                    );
                  }
                } catch (e) {
                  print('Error creating collection: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to create collection: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildAuthenticatedContent() {
    return FutureBuilder<WishlistCollection>(
      future: futureCollections,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('FutureBuilder error: ${snapshot.error}');
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

        // Tambahkan pengecekan untuk results
        if (!snapshot.hasData || snapshot.data!.results.isEmpty) {
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

        // Show collections in a grid
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: snapshot.data!.results.length,
          itemBuilder: (context, index) {
            final collection = snapshot.data!.results[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => WishlistDetailPage(
                      collection: collection,
                    ),
                  ),
                );
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
                                padding: const EdgeInsets.all(8),
                                children: collection.items
                                    .take(4)
                                    .map((item) => Card(
                                          child: Center(
                                            child: Text(
                                              item.menuItem.name,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(fontSize: 10),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              collection.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${collection.itemsCount} items',
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
    );
  }

  Widget buildUnauthenticatedContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Please login to view your wishlist',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to login page
              Navigator.pushNamed(context, '/login').then((_) {
                // Check authentication after returning from login page
                isAuthenticated().then((authenticated) {
                  if (authenticated) {
                    loadCollections();
                  }
                });
              });
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
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
            onPressed: () async {
              if (await isAuthenticated()) {
                createCollection(); // Panggil method createCollection yang baru
              } else {
                Navigator.pushNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<bool>(
        future: isAuthenticated(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!) {
            // Don't load collections here anymore
            return buildAuthenticatedContent();
          }

          return buildUnauthenticatedContent();
        },
      ),
    );
  }
}