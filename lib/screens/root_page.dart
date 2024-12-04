import 'package:flutter/material.dart';
import 'package:southfeast_mobile/product/screens/product.dart';
import 'package:southfeast_mobile/forum/screens/forum.dart';
import 'package:southfeast_mobile/review/screens/review.dart';
import 'package:southfeast_mobile/screens/homepage.dart';
import 'package:southfeast_mobile/wishlist/screens/wishlist.dart';
import 'package:southfeast_mobile/dashboard/screens/dashboard.dart';
import 'package:southfeast_mobile/restaurant/screens/restaurant.dart';
import 'package:southfeast_mobile/authentication/screens/login.dart';
import '../widgets/app_bar.dart';
import '../widgets/left_drawer.dart';
import 'package:responsive_navigation_bar/responsive_navigation_bar.dart';
// import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';

class RootPage extends StatefulWidget {
  final bool isStaff;
  final bool isAuthenticated;
  final int initialIndex;
  final String? username;

  const RootPage({
    super.key,
    required this.isStaff,
    required this.isAuthenticated,
    this.initialIndex = 0,
    this.username,
  });

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  late int _selectedIndex;
  late bool isAuthenticated;

  @override
  void initState() {
    super.initState();
    isAuthenticated = widget.isAuthenticated;
    _selectedIndex = widget.initialIndex;
  }

  List<Map<String, dynamic>> _getMenuItems() {
    if (widget.isStaff) {
      return [
        {
          "title": "Home",
          "icon": Icons.home,
          "screen": MyHomePage(
              isStaff: widget.isStaff, isAuthenticated: widget.isAuthenticated),
          "requiresAuth": false,
        },
        {
          "title": "Dashboard",
          "icon": Icons.dashboard,
          "screen": const DashboardPage(),
          "requiresAuth": true,
        },
        {
          "title": "Review",
          "icon": Icons.rate_review,
          "screen": const ReviewPage(),
          "requiresAuth": false,
        },
        {
          "title": "Forum",
          "icon": Icons.forum,
          "screen": const ForumPage(),
          "requiresAuth": false,
        },
      ];
    } else {
      return [
        {
          "title": "Home",
          "icon": Icons.home,
          "screen": MyHomePage(
              isStaff: widget.isStaff, isAuthenticated: widget.isAuthenticated),
          "requiresAuth": false,
        },
        {
          "title": "Catalog",
          "icon": Icons.shopping_cart,
          "screen": const ProductPage(),
          "requiresAuth": false,
        },
        {
          "title": "Restaurant",
          "icon": Icons.restaurant,
          "screen": const RestaurantPage(),
          "requiresAuth": false,
        },
        {
          "title": "Wishlist",
          "icon": Icons.favorite,
          "screen": const WishlistPage(),
          "requiresAuth": true,
        },
        {
          "title": "Culinary Insights",
          "icon": Icons.forum,
          "screen": const ForumPage(),
          "requiresAuth": false,
        },
        {
          "title": "Review",
          "icon": Icons.rate_review,
          "screen": const ReviewPage(),
          "requiresAuth": false,
        },
      ];
    }
  }

  void _onItemTapped(int index) {
    final menuItems = _getMenuItems();
    final selectedItem = menuItems[index];

    if (selectedItem['requiresAuth'] && !widget.isAuthenticated) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = _getMenuItems();

    return Scaffold(
      appBar: GlobalAppBar(
        isAuthenticated: isAuthenticated,
        onAuthStateChanged: () {
          setState(() {
            isAuthenticated = !isAuthenticated;
          });
        },
      ),
      drawer: LeftDrawer(
        isStaff: widget.isStaff,
        isAuthenticated: isAuthenticated,
      ),
      extendBody: true,
      body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: menuItems[_selectedIndex]['screen'] as Widget),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
        child: ResponsiveNavigationBar(
          backgroundColor: Colors.black,
          backgroundOpacity: 0.5,
          backgroundBlur: 1,
          showActiveButtonText: false,
          inactiveIconColor: Colors.white,
          activeIconColor: Colors.white,
          selectedIndex: _selectedIndex,
          onTabChange: _onItemTapped,
          textStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          navigationBarButtons: menuItems
              .map((item) => NavigationBarButton(
                    text: item['title'] as String,
                    icon: item['icon'] as IconData,
                    backgroundColor: Colors.black,
                  ))
              .toList(),
        ),
      ),
    );
  }
}
