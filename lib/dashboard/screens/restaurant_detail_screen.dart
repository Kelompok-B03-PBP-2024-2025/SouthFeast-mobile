// restaurant_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:southfeast_mobile/dashboard/models/product/result.dart';
import 'package:southfeast_mobile/dashboard/screens/detail_makanan.dart';
import 'package:southfeast_mobile/dashboard/screens/edit_restaurant.dart';
import 'package:southfeast_mobile/restaurant/models/restaurant_detail/restaurant_detail.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:southfeast_mobile/dashboard/screens/makanan_form.dart';
import 'package:southfeast_mobile/dashboard/screens/edit_makanan.dart';
import 'package:southfeast_mobile/widgets/custom_bottom_nav.dart';
import 'package:southfeast_mobile/config/menu_config.dart';
import 'package:southfeast_mobile/authentication/screens/login.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantName;
  final bool isStaff;
  final bool isAuthenticated;

  const RestaurantDetailScreen({
    Key? key, 
    required this.restaurantName,
    this.isStaff = false,
    this.isAuthenticated = false,
  }) : super(key: key);

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  RestaurantDetail? restaurantDetail;
  bool isLoading = true;
  String? error;
  late int _selectedIndex = widget.isStaff ? 1 : 0;

  @override
  void initState() {
    super.initState();
    fetchRestaurantDetail();
  }

  Future<void> fetchRestaurantDetail() async {
    final request = context.read<CookieRequest>();
    
    try {
      setState(() {
        isLoading = true;
      });

      final response = await request.get(
        'https://southfeast-production.up.railway.app/restaurant/restaurant-detail-json/${widget.restaurantName}/'
      );

      if (response != null) {
        setState(() {
          restaurantDetail = RestaurantDetail.fromJson(response);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load restaurant data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Restaurant Detail"),
        titleTextStyle: const TextStyle(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Restaurant Header Card
                      Container(
                        color: Colors.black,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    restaurantDetail?.restaurant?.name ?? 'N/A',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.white),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditRestaurantForm(
                                          restaurant: restaurantDetail?.restaurant?.toJson() ?? {}
                                        ),
                                      ),
                                    );
                                    
                                    if (result == true && mounted) {
                                      fetchRestaurantDetail(); // Refresh the data
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.white),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${restaurantDetail?.restaurant?.kecamatan ?? 'N/A'} - ${restaurantDetail?.restaurant?.location ?? 'N/A'}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Stats Cards
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            _buildStatCard(
                              'Menu Items',
                              '${restaurantDetail?.stats?.menuCount ?? 0}',
                              Icons.restaurant_menu,
                            ),
                            const SizedBox(width: 16),
                            _buildStatCard(
                              'Avg Price',
                              'Rp${restaurantDetail?.stats?.avgPrice?.toStringAsFixed(0) ?? 'N/A'}',
                              Icons.payments,
                            ),
                          ],
                        ),
                      ),

                      // Menu Items Section
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Menu Items',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: restaurantDetail?.menuItems?.length ?? 0,
                              itemBuilder: (context, index) {
                                final menuItem = restaurantDetail?.menuItems?[index];
                                final screenWidth = MediaQuery.of(context).size.width;
                                final imageSize = screenWidth < 360 ? 80.0 : screenWidth < 600 ? 100.0 : 120.0;
                                final horizontalPadding = screenWidth < 360 ? 8.0 : 12.0;
                                final fontSize = screenWidth < 360 ? 14.0 : 16.0;

                                return Card(
                                  elevation: 4,
                                  margin: EdgeInsets.symmetric(
                                    vertical: horizontalPadding * 0.5,
                                    horizontal: horizontalPadding,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Slidable(
                                      endActionPane: ActionPane(
                                        motion: const ScrollMotion(),
                                        extentRatio: 0.5,
                                        children: [
                                          CustomSlidableAction(
                                            flex: 1,
                                            onPressed: (_) => _handleEdit(menuItem),
                                            backgroundColor: Colors.blue.shade400,
                                            foregroundColor: Colors.white,
                                            child: const Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.edit),
                                                SizedBox(height: 4),
                                                Text('Edit', style: TextStyle(fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                          CustomSlidableAction(
                                            flex: 1,
                                            onPressed: (_) => _handleDelete(menuItem),
                                            backgroundColor: Colors.red.shade400,
                                            foregroundColor: Colors.white,
                                            child: const Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.delete),
                                                SizedBox(height: 4),
                                                Text('Delete', style: TextStyle(fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      child: InkWell(
                                        onTap: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => DetailMakanan(
                                                result: Result(
                                                  id: menuItem?.id,
                                                  name: menuItem?.name,
                                                  description: menuItem?.description,
                                                  price: menuItem?.price,
                                                  image: menuItem?.image,
                                                  category: menuItem?.category,
                                                  restaurantName: restaurantDetail?.restaurant?.name,
                                                  kecamatan: restaurantDetail?.restaurant?.kecamatan,
                                                  location: restaurantDetail?.restaurant?.location,
                                                ),
                                                onUpdate: () => fetchRestaurantDetail(), isStaff: true, isAuthenticated: true,
                                              ),
                                            ),
                                          );

                                          if (result == true) {
                                            fetchRestaurantDetail();
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                            gradient: LinearGradient(
                                              colors: [Colors.white, Colors.grey.shade50],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                          padding: EdgeInsets.all(horizontalPadding),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: SizedBox(
                                                  width: imageSize,
                                                  height: imageSize,
                                                  child: menuItem?.image != null
                                                      ? Image.network(
                                                          menuItem!.image!,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context, error, stackTrace) {
                                                            return Container(
                                                              color: Colors.grey.shade200,
                                                              child: Icon(
                                                                Icons.broken_image_outlined,
                                                                size: imageSize * 0.4,
                                                                color: Colors.grey,
                                                              ),
                                                            );
                                                          },
                                                        )
                                                      : Container(
                                                          color: Colors.grey.shade200,
                                                          child: Icon(
                                                            Icons.image_not_supported,
                                                            size: imageSize * 0.4,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                              SizedBox(width: horizontalPadding),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      menuItem?.name ?? 'Unnamed Item',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: fontSize,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      menuItem?.category ?? 'No Category',
                                                      style: TextStyle(
                                                        fontSize: fontSize - 2,
                                                        color: Colors.grey.shade600,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Rp${menuItem?.price ?? 'N/A'}',
                                                      style: TextStyle(
                                                        fontSize: fontSize - 2,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      menuItem?.description ?? 'No description',
                                                      style: TextStyle(
                                                        fontSize: fontSize - 2,
                                                        color: Colors.grey.shade700,
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: CustomBottomNavigationBar(
        menuItems: MenuConfig.getMenuItems(
          isStaff: widget.isStaff,
          isAuthenticated: widget.isAuthenticated,
          username: null,
        ),
        selectedIndex: _selectedIndex,
        onTap: (index) {
          if (index != _selectedIndex) {
            Navigator.pop(context);
          }
        },
        isAuthenticated: widget.isAuthenticated,
        onAuthCheck: (context, item) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
      ),
      extendBody: true,
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 24, color: Colors.black),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleEdit(dynamic menuItem) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMakananForm(
          makanan: {
            'id': menuItem?.id,
            'name': menuItem?.name,
            'description': menuItem?.description,
            'price': menuItem?.price,
            'image': menuItem?.image,
            'category': menuItem?.category,
            'restaurant_name': restaurantDetail?.restaurant?.name,
            'kecamatan': restaurantDetail?.restaurant?.kecamatan,
            'location': restaurantDetail?.restaurant?.location,
          },
        ),
      ),
    );
    
    if (result != null) {
      fetchRestaurantDetail(); // Refresh the data after successful edit
    }
  }

  Future<void> _handleDelete(dynamic menuItem) async {
    try {
      final bool shouldDelete = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: const Text('Delete'),
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all<Color>(Colors.red),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        ),
      ) ?? false;

      if (shouldDelete) {
        final request = context.read<CookieRequest>();
        final deleteUrl = 'https://southfeast-production.up.railway.app/dashboard/delete-makanan-flutter/${menuItem.id}/';
        final response = await request.get(deleteUrl);

        if (response['status'] == 'success') {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Item deleted successfully')),
            );
          }
          fetchRestaurantDetail();
        } else {
          throw Exception(response['message'] ?? 'Unknown error');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}