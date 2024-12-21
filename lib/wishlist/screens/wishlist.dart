// lib/screens/wishlist.dart
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/wishlist_collection.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  late Future<WishlistCollection> futureCollections;
  final String baseUrl = 'https://southfeast-production.up.railway.app/wishlist';

  Future<WishlistCollection> getCollections() async {
    final request = context.read<CookieRequest>();
    try {
      final url = '$baseUrl/flutter/collections/';
      print('Fetching collections from: $url');
      print('Request headers: ${request.headers}');  // Tambahan print
      
      final response = await request.get(url);
      print('Raw Response: $response');  // Tambahan print

      if (response == null) {
        throw Exception('Response is null');
      }

      final wrappedResponse = {
        "results": response,
        "total_pages": 1,
        "current_page": 1,
        "has_previous": false,
        "has_next": false,
        "total_items": response is List ? response.length : 0,
        "filter_type": "all",
        "search_query": ""
      };

      print('Wrapped Response: $wrappedResponse');  // Tambahan print
      return WishlistCollection.fromJson(wrappedResponse);
    } catch (e, stackTrace) {
      print('Error type: ${e.runtimeType}');  // Tambahan print
      print('Error details: $e');  // Tambahan print
      print('Stack trace: $stackTrace');  // Tambahan print
      throw Exception('Failed to load collections: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    futureCollections = getCollections();
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
              // TODO: Implement add collection
            },
          ),
        ],
      ),
      body: FutureBuilder<WishlistCollection>(
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
              return Card(
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
              );
            },
          );
        },
      ),
    );
  }
}