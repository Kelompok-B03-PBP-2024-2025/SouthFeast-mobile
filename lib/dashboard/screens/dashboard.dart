// lib/screens/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:southfeast_mobile/dashboard/models/product/product.dart';
import 'package:southfeast_mobile/dashboard/models/product/result.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:southfeast_mobile/dashboard/widgets/filter_bottom_sheet.dart';
import 'package:southfeast_mobile/dashboard/widgets/product_grid.dart';
import 'package:southfeast_mobile/dashboard/widgets/search_filter_bar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentPage = 1;
  String _selectedCategory = 'all';
  String _selectedKecamatan = 'all';
  List<String> _categories = ['all'];
  List<String> _kecamatans = ['all'];
  List<Result> _products = [];
  bool _hasNext = false;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  // Controllers for price range
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = context.read<CookieRequest>();
      fetchProducts(request);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasNext) {
        final request = context.read<CookieRequest>();
        fetchProducts(request, page: _currentPage + 1);
      }
    }
  }

  Future<void> fetchProducts(CookieRequest request, {int page = 1}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await request.get(
        // 'http://10.0.2.2:8000/dashboard/show-json/?page=$page&'
        'http://127.0.0.1:8000/dashboard/show-json/?page=$page&'
        'search=${_searchController.text}&'
        'category=$_selectedCategory&'
        'kecamatan=$_selectedKecamatan&'
        'min_price=${_minPriceController.text}&'
        'max_price=${_maxPriceController.text}'
      );
      
      if (response != null) {
        Product productData = Product.fromMap(response);
        
        setState(() {
          // Convert lists to Sets to ensure uniqueness, then back to List
          if (_categories.length == 1) {
            Set<String> uniqueCategories = Set<String>.from(
              response['categories']?.cast<String>() ?? []
            );
            _categories = ['all', ...uniqueCategories];
          }
          if (_kecamatans.length == 1) {
            Set<String> uniqueKecamatans = Set<String>.from(
              response['kecamatans']?.cast<String>() ?? []
            );
            _kecamatans = ['all', ...uniqueKecamatans];
          }

          // Update products
          if (page == 1) {
            _products = productData.results ?? [];
          } else {
            _products.addAll(productData.results ?? []);
          }

          _currentPage = productData.currentPage ?? 1;
          _hasNext = productData.hasNext ?? false;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products: $e')),
      );
    }
  }

  void _applyFilters() {
    _currentPage = 1; // Reset to first page when applying filters
    final request = context.read<CookieRequest>();
    fetchProducts(request, page: 1);
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      body: Column(
        children: [
          SearchFilterBar(
            searchController: _searchController,
            categories: _categories,
            selectedCategory: _selectedCategory,
            onCategorySelected: (value) {
              setState(() {
                _selectedCategory = value;
              });
              _applyFilters();
            },
            kecamatans: _kecamatans,
            selectedKecamatan: _selectedKecamatan,
            onKecamatanSelected: (value) {
              setState(() {
                _selectedKecamatan = value;
              });
              _applyFilters();
            },
            onFilterPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (BuildContext context) {
                  return FilterBottomSheet(
                    minPriceController: _minPriceController,
                    maxPriceController: _maxPriceController,
                    categories: _categories,
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    kecamatans: _kecamatans,
                    selectedKecamatan: _selectedKecamatan,
                    onKecamatanSelected: (value) {
                      setState(() {
                        _selectedKecamatan = value;
                      });
                    },
                    onApplyFilters: _applyFilters,
                  );
                },
              );
            },
            onSearchSubmitted: (value) {
              _applyFilters();
            },
          ),
          Expanded(
            child: _products.isEmpty && !_isLoading
                ? const Center(child: Text('No products found'))
                : ProductGrid(
                    products: _products,
                    scrollController: _scrollController,
                    isLoading: _isLoading,
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Clean up controllers
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}