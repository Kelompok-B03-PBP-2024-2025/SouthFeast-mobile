// lib/screens/wishlist_detail.dart
import 'package:flutter/material.dart';
import '../models/wishlist_collection.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'widgets/edit_collection_dialog.dart';

class WishlistDetailPage extends StatefulWidget {
  final Result collection;

  const WishlistDetailPage({
    super.key,
    required this.collection,
  });

  @override
  State<WishlistDetailPage> createState() => _WishlistDetailPageState();
}

class _WishlistDetailPageState extends State<WishlistDetailPage> {
  final String baseUrl = 'http://10.0.2.2:8000/wishlist'; // NANTI INI HARUS DIGANTI

  Future<void> removeItem(int itemId) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        '$baseUrl/flutter/wishlist/$itemId/remove/',
        {}
      );
      
      if (response['status'] == 'success') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item removed successfully')),
          );
          Navigator.pop(context, true); // Refresh parent
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove item: $e')),
        );
      }
    }
  }

  void showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => EditCollectionDialog(
        collection: widget.collection,
      ),
    ).then((result) async {
      if (result == true) {
        // Collection updated, refresh page
        Navigator.pop(context, true);
      } else if (result == 'delete') {
        // Delete collection
        final request = context.read<CookieRequest>();
        try {
          final response = await request.post(
            '$baseUrl/flutter/collections/${widget.collection.id}/delete/',
            {},
          );

          if (response['status'] == 'success') {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Collection deleted successfully')),
              );
              Navigator.pop(context, true);
            }
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Collection Detail',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!widget.collection.isDefault)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: showEditDialog,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.collection.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.collection.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  widget.collection.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            if (widget.collection.items.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'No items in this collection yet.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: widget.collection.items.length,
                itemBuilder: (context, index) {
                  final item = widget.collection.items[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.grey[200],
                            alignment: Alignment.center,
                            child: Text(
                              item.menuItem.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Rp ${item.menuItem.price}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      if (widget.collection.name == "My Wishlist")
                                        IconButton(
                                          icon: const Icon(
                                            Icons.add_circle_outline,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            // TODO: Show add to collection dialog
                                          },
                                        ),
                                      if (!widget.collection.isDefault)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.move_down,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            // TODO: Show move dialog
                                          },
                                        ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          size: 20,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => removeItem(item.id),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}