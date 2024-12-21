// restaurant_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:southfeast_mobile/dashboard/models/product/result.dart';
import 'package:southfeast_mobile/dashboard/screens/detail_makanan.dart';
import 'package:southfeast_mobile/dashboard/screens/edit_restaurant.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:southfeast_mobile/dashboard/screens/edit_makanan.dart';
import 'package:southfeast_mobile/widgets/custom_bottom_nav.dart';
import 'package:southfeast_mobile/config/menu_config.dart';
import 'package:southfeast_mobile/authentication/screens/login.dart';
import 'package:southfeast_mobile/restaurant/services/restaurant_service.dart'; 
import 'package:southfeast_mobile/restaurant/models/restaurant/restaurant.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final RestaurantElement restaurant;
  final bool isStaff;
  final bool isAuthenticated;
  final VoidCallback? onRefresh;

  const RestaurantDetailScreen({
    Key? key, 
    required this.restaurant,
    this.isStaff = true,
    this.isAuthenticated = true,
    this.onRefresh,
  }) : super(key: key);

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  // Add restaurant state
  late RestaurantElement _restaurant;
  late int _selectedIndex = widget.isStaff ? 1 : 0;

  @override
  void initState() {
    super.initState();
    _restaurant = widget.restaurant;
  }

  Future<void> _refreshRestaurantData() async {
    final request = context.read<CookieRequest>();
    final updatedRestaurant = await RestaurantService.fetchRestaurantDetail(
      request,
      _restaurant.id,
    );
    if (updatedRestaurant != null && mounted) {
      setState(() {
        _restaurant = updatedRestaurant;
      });
      widget.onRefresh?.call(); // Notify parent of update
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: const Text(
        "Restaurant Detail",
        style: TextStyle(fontSize:22), // Increased font size
      ),
      titleTextStyle: const TextStyle(color: Colors.white),
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: Colors.black,
      elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshRestaurantData,
        child: SingleChildScrollView(
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
                            _restaurant.name, // Use state instead of widget
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
                                  restaurant: _restaurant.toJson() // Use state
                                ),
                              ),
                            );
                            
                            if (result != null && mounted) {
                              setState(() {
                                _restaurant = RestaurantElement.fromJson(result);
                              });
                              // Ensure parent refreshes
                              widget.onRefresh?.call();
                              // Make sure changes propagate back
                              
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
                            '${_restaurant.kecamatan} - ${_restaurant.location}', // Use state
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
                      '${_restaurant.menuCount}',
                      Icons.restaurant_menu,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      'Avg Price',
                      'Rp${_restaurant.avgPrice}',
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
                      itemCount: _restaurant.menus.length,
                      itemBuilder: (context, index) {
                        final menuItem = _restaurant.menus[index];
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
                                    backgroundColor: const Color.fromARGB(255, 0, 32, 70),
                                    foregroundColor: Colors.white,
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.edit),
                                        SizedBox(height: 4),
          
                                      ],
                                    ),
                                  ),
                                  CustomSlidableAction(
                                    flex: 1,
                                    onPressed: (_) => _handleDelete(menuItem),
                                    backgroundColor: const Color.fromARGB(255, 97, 2, 0),
                                    foregroundColor: Colors.white,
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.delete),
                                        SizedBox(height: 4),
                                        
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
                                          id: menuItem.id,
                                          name: menuItem.name,
                                          description: menuItem.description,
                                          price: menuItem.price,
                                          image: menuItem.image,
                                          category: menuItem.category,
                                          restaurantName: _restaurant.name,
                                          kecamatan: _restaurant.kecamatan,
                                          location: _restaurant.location,
                                        ),
                                        onUpdate: () async {
                                          // Add async callback
                                          await _refreshRestaurantData();
                                          return true; // Return true to indicate successful update
                                        }, 
                                        isStaff: true, 
                                        isAuthenticated: true,
                                      ),
                                    ),
                                  );

                                  if (result == true) {
                                    await _refreshRestaurantData();
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
                                          child: menuItem.image != null
                                              ? Image.network(
                                                  menuItem.image!,
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
                                              menuItem.name ?? 'Unnamed Item',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: fontSize,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              menuItem.category ?? 'No Category',
                                              style: TextStyle(
                                                fontSize: fontSize - 2,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Rp${menuItem.price ?? 'N/A'}',
                                              style: TextStyle(
                                                fontSize: fontSize - 2,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              menuItem.description ?? 'No description',
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
    if (!mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMakananForm(
          makanan: {
            'id': menuItem.id,
            'name': menuItem.name ?? '',
            'description': menuItem.description ?? '',
            'price': menuItem.price ?? '0',
            'image': menuItem.image ?? '',
            'category': menuItem.category ?? '',
            'restaurant_name': _restaurant.name,
            'kecamatan': _restaurant.kecamatan,
            'location': _restaurant.location,
          },
        ),
      ),
    );
    
    if (result != null && mounted) {
      await _refreshRestaurantData(); // Refresh local data
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
                foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
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
          
          final updatedRestaurant = await RestaurantService.fetchRestaurantDetail(
            request,
            _restaurant.id,
          );
          
          if (updatedRestaurant != null && mounted) {
            if (updatedRestaurant.menuCount == 0) {
              widget.onRefresh?.call(); 
              Navigator.pop(context, true); // Go back if no menus left
            } else {
              setState(() {
                _restaurant = updatedRestaurant;
              });
              widget.onRefresh?.call();
            }
          }
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