import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:southfeast_mobile/dashboard/widgets/search_filter_bar.dart';
import 'package:southfeast_mobile/restaurant/models/restaurant/restaurant.dart';
import 'package:southfeast_mobile/restaurant/services/restaurant_service.dart';
import 'package:southfeast_mobile/dashboard/widgets/restaurant_list.dart';
import 'package:southfeast_mobile/dashboard/widgets/restaurant_filter_bar.dart';

class RestaurantPage extends StatefulWidget {
  const RestaurantPage({Key? key}) : super(key: key);

  @override
  _RestaurantPageState createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> with AutomaticKeepAliveClientMixin {
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
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() => _fetchRestaurants());
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
      
      final restaurantData = await RestaurantService.fetchRestaurants(
        request,
        search: _searchController.text,
        kecamatan: _selectedKecamatan,
        page: page,
      );

      if (mounted) {
        setState(() {
          // Only clear the list if we're fetching page 1
          if (page == 1) {
            _restaurants = restaurantData.restaurants;
            _kecamatans = ['all', ...restaurantData.kecamatans];
          } else {
            // For subsequent pages, append to existing list
            _restaurants.addAll(restaurantData.restaurants);
          }
          _currentPage = restaurantData.currentPage;
          _hasNext = restaurantData.hasNext;
          _totalPages = restaurantData.totalPages;
          _isLoading = false;
        });
      }
      
    } catch (e) {
      print('Error in _fetchRestaurants: $e'); // Debug print for errors
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching restaurants: $e')),
      );
    }
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    
    // Don't reset current page, just refresh the current state
    try {
      await _fetchRestaurants(page: _currentPage);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing data: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    _currentPage = 1;
    _restaurants.clear();
    _fetchRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: _restaurants.isEmpty && !_isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RestaurantList(
                      restaurants: _restaurants,
                      scrollController: _scrollController,
                      isLoading: _isLoading,
                      onRefresh: _refreshData,
                    ),
            ),
          ),
        ],
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

