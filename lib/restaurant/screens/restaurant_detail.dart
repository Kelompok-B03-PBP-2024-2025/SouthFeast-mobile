import 'package:flutter/material.dart';
import 'package:southfeast_mobile/dashboard/models/product/result.dart';
import 'package:southfeast_mobile/product/screens/detail_makanan.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:southfeast_mobile/reservation/screens/reservation_create.dart';
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
  final int? userID;

  const RestaurantDetailScreen({
    Key? key, 
    required this.restaurant,
    this.isStaff = false,
    this.isAuthenticated = false,
    this.onRefresh,
    this.userID,
  }) : super(key: key);

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  late RestaurantElement _restaurant;
  late int _selectedIndex = widget.isStaff ? 3 : 0;

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
      widget.onRefresh?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Restaurant Detail"),
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
                    Text(
                      _restaurant.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_restaurant.kecamatan} - ${_restaurant.location}',
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

              // Reservation Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!widget.isAuthenticated) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReservationCreateScreen(
                            restaurantName: _restaurant.name,
                            restaurantId: _restaurant.id,  // Tambahkan ini
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 8),
                        Text(
                          'Make a Reservation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

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
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
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
                                      isStaff: false, 
                                      isAuthenticated: widget.isAuthenticated,
                                    ),
                                  ),
                                );
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
                                              color: Colors.green,
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
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
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
}