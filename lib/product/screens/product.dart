import 'package:flutter/material.dart';
import 'package:southfeast_mobile/dashboard/models/product/product.dart';
import 'package:southfeast_mobile/dashboard/models/product/result.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:southfeast_mobile/dashboard/widgets/filter_bottom_sheet.dart';
import 'package:southfeast_mobile/dashboard/widgets/product_grid.dart';
import 'package:southfeast_mobile/dashboard/widgets/search_filter_bar.dart';
import 'package:southfeast_mobile/dashboard/screens/makanan_form.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int _currentPage = 1;
  String _selectedCategory = 'all';
  String _selectedKecamatan = 'all';
  List<String> _categories = ['all'];
  List<String> _kecamatans = ['all'];
  List<Result> _products = [];
  Set<int> _wishlistedProducts = {}; // Track wishlisted products
  bool _hasNext = false;
  bool _isLoading = false;
  bool _isAdmin = false;
  final ScrollController _scrollController = ScrollController();

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
      checkAdminStatus(request);
      loadWishlist(); // Load saved wishlist
    });
  }

  // Add method to load wishlist from local storage or API
  Future<void> loadWishlist() async {
    // Implement loading wishlist from storage/API
    // For now, we'll just initialize an empty set
    setState(() {
      _wishlistedProducts = {};
    });
  }

  // Add method to toggle wishlist status
  Future<void> toggleWishlist(int productId) async {
    final request = context.read<CookieRequest>();
    if (!request.loggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add items to wishlist'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      // Here you would typically make an API call to update the wishlist
      // For now, we'll just update the local state
      setState(() {
        if (_wishlistedProducts.contains(productId)) {
          _wishlistedProducts.remove(productId);
        } else {
          _wishlistedProducts.add(productId);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating wishlist: $e')),
      );
    }
  }

  Future<void> checkAdminStatus(CookieRequest request) async {
    try {
      final response = await request.get(
        'https://southfeast-production.up.railway.app/auth/check-admin/'
      );
      setState(() {
        _isAdmin = response['is_admin'] ?? false;
      });
    } catch (e) {
      setState(() {
        _isAdmin = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
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
        'https://southfeast-production.up.railway.app/dashboard/show-json/?page=$page&'
        'search=${_searchController.text}&'
        'category=$_selectedCategory&'
        'kecamatan=$_selectedKecamatan&'
        'min_price=${_minPriceController.text}&'
        'max_price=${_maxPriceController.text}'
      );
      
      if (response != null) {
        Product productData = Product.fromMap(response);

        setState(() {
          if (_categories.length == 1) {
            Set<String> uniqueCategories =
                Set<String>.from(response['categories']?.cast<String>() ?? []);
            _categories = ['all', ...uniqueCategories];
          }
          if (_kecamatans.length == 1) {
            Set<String> uniqueKecamatans =
                Set<String>.from(response['kecamatans']?.cast<String>() ?? []);
            _kecamatans = ['all', ...uniqueKecamatans];
          }

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
    _currentPage = 1;
    final request = context.read<CookieRequest>();
    fetchProducts(request, page: 1);
  }

  void _showFilterBottomSheet(BuildContext context) {
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
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isLoggedIn = request.loggedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Catalog'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (!isLoggedIn)
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              icon: const Icon(Icons.login, color: Colors.white),
              label: const Text(
                'Login',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth < 600 ? 8.0 : 16.0),
            child: Column(
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
                  onFilterPressed: () => _showFilterBottomSheet(context),
                  onSearchSubmitted: (value) {
                    _applyFilters();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _products.isEmpty && !_isLoading
                ? const Center(child: Text('No products found'))
                : ProductGrid(
                    products: _products,
                    scrollController: _scrollController,
                    isLoading: _isLoading,
                    onUpdate: () {
                      _currentPage = 1;
                      fetchProducts(request, page: 1);
                    },
                    isAdmin: false, // Always set to false to hide edit/delete buttons
                    wishlistedProducts: _wishlistedProducts,
                    onWishlistToggle: toggleWishlist,
                  ),
          ),
        ],
      ),
      floatingActionButton: _isAdmin ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MakananForm()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.black,
      ) : null,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}