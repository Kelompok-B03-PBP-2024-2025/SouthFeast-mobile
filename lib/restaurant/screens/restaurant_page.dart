import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:southfeast_mobile/dashboard/widgets/search_filter_bar.dart';
import 'package:southfeast_mobile/reservation/screens/reservation_viewall.dart';
import 'package:southfeast_mobile/restaurant/models/restaurant/restaurant.dart';
import 'package:southfeast_mobile/restaurant/services/restaurant_service.dart';
import 'package:southfeast_mobile/restaurant/widgets/restaurant_filter_bar.dart';
import 'package:southfeast_mobile/restaurant/widgets/restaurant_grid.dart';
import 'package:southfeast_mobile/reservation/screens/reservation_detail.dart';

class RestaurantPage extends StatefulWidget {
  @override
  _RestaurantPageState createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  List<RestaurantElement> _restaurants = [];
  List<String> _kecamatans = ['all'];
  String _selectedKecamatan = 'all';
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasNext = true;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchRestaurants();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasNext) {
        _fetchRestaurants(page: _currentPage + 1);
      }
    }
  }

  Future<void> _fetchRestaurants({int page = 1}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final request = context.read<CookieRequest>();
      print('Fetching restaurants - Page: $page, Search: ${_searchController.text}, Kecamatan: $_selectedKecamatan}');
      
      final restaurantData = await RestaurantService.fetchRestaurants(
        request,
        search: _searchController.text,
        kecamatan: _selectedKecamatan,
        page: page,
      );

      print('Received ${restaurantData.restaurants.length} restaurants');

      setState(() {
        if (page == 1) {
          _restaurants = restaurantData.restaurants;
          _kecamatans = ['all', ...restaurantData.kecamatans];
        } else {
          _restaurants.addAll(restaurantData.restaurants);
        }
        _currentPage = restaurantData.currentPage;
        _hasNext = restaurantData.hasNext;
        _totalPages = restaurantData.totalPages;
        _isLoading = false;
      });
      
    } catch (e) {
      print('Error in _fetchRestaurants: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching restaurants: $e')),
      );
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _currentPage = 1;
      _restaurants.clear();
      _isLoading = true;
    });
    await _fetchRestaurants();
  }

  void _applyFilters() {
    _currentPage = 1;
    _restaurants.clear();
    _fetchRestaurants();
  }

  Future<void> _handleReservationsNavigation() async {
    final request = context.read<CookieRequest>();
    
    // Check if user is logged in by checking the cookies
    final isLoggedIn = request.loggedIn;
    
    if (!isLoggedIn) {
      // Show login dialog
      final shouldNavigate = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Required'),
          content: const Text('You need to be logged in to view reservations. Would you like to login?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Login'),
            ),
          ],
        ),
      );

      if (shouldNavigate == true) {
        // Navigate to login page
        Navigator.pushNamed(context, '/login').then((value) {
          // After login, check if user is now logged in
          if (request.loggedIn) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReservationViewAllScreen(),
              ),
            );
          }
        });
      }
    } else {
      // User is logged in, navigate directly to reservations
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ReservationViewAllScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          RestaurantFilterBar(
            searchController: _searchController,
            kecamatans: _kecamatans,
            selectedKecamatan: _selectedKecamatan,
            onKecamatanSelected: (value) {
              setState(() {
                _selectedKecamatan = value;
              });
              _applyFilters();
            },
            onSearchSubmitted: (_) => _applyFilters(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleReservationsNavigation,
                icon: const Icon(Icons.book_online),
                label: const Text('My Reservations'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: RestaurantList(
                restaurants: _restaurants,
                scrollController: _scrollController,
                isLoading: _isLoading,
                onRefresh: () => _refreshData(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleReservationsNavigation,
        label: const Text('My Reservations'),
        icon: const Icon(Icons.book_online),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}