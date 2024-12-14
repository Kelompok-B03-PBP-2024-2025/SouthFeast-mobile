import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:southfeast_mobile/dashboard/widgets/search_filter_bar.dart';
import 'package:southfeast_mobile/restaurant/models/restaurant/restaurant_model.dart';
import 'package:southfeast_mobile/restaurant/services/restaurant_service.dart';
import 'package:southfeast_mobile/dashboard/widgets/restaurant_list.dart';
import 'package:southfeast_mobile/dashboard/widgets/restaurant_filter_bar.dart';

class RestaurantPage extends StatefulWidget {
  @override
  _RestaurantPageState createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  List<Restaurant> _restaurants = [];
  List<String> _kecamatans = [
    'all',
    'Cilandak',
    'Jagakarsa',
    'Kebayoran Baru',
    'Kebayoran Lama',
    'Mampang Prapatan',
    'Pancoran',
    'Pasar Minggu',
    'Setiabudi',
    'Tebet'
  ];
  String _selectedKecamatan = 'all';
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasNext = true;

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
      
      final restaurants = await RestaurantService.fetchRestaurants(
        request,
        search: _searchController.text,
        kecamatan: _selectedKecamatan,
        page: page,
      );

      print('Received ${restaurants.length} restaurants'); // Debug print

      setState(() {
        if (page == 1) {
          _restaurants = restaurants;
        } else {
          _restaurants.addAll(restaurants);
        }
        _currentPage = page;
        _hasNext = restaurants.isNotEmpty;
        _isLoading = false;
      });
      
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

  void _applyFilters() {
    _currentPage = 1;
    _restaurants.clear();
    _fetchRestaurants();
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
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _currentPage = 1;
                  _restaurants.clear();
                });
                await _fetchRestaurants();
              },
              child: RestaurantList(
                restaurants: _restaurants,
                scrollController: _scrollController,
                isLoading: _isLoading,
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

