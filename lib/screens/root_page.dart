import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:southfeast_mobile/product/screens/product.dart';
import 'package:southfeast_mobile/forum/screens/forum.dart';
import 'package:southfeast_mobile/review/screens/review.dart';
import 'package:southfeast_mobile/wishlist/screens/wishlist.dart';
import 'package:southfeast_mobile/dashboard/screens/dashboard.dart';
import 'package:southfeast_mobile/restaurant/screens/restaurant.dart';
import 'package:southfeast_mobile/screens/homepage.dart';
import 'package:southfeast_mobile/authentication/screens/login.dart';  // Add this import
import '../widgets/app_bar.dart';
import '../widgets/left_drawer.dart';  // Add this import

class RootPage extends StatefulWidget {
  final bool isStaff;
  final bool isAuthenticated;
  final int initialIndex;
  final String? username;  // Add this

  const RootPage({
    super.key,
    required this.isStaff,
    required this.isAuthenticated,
    this.initialIndex = 0,  // Add this parameter with a default value of 0
    this.username,  // Add this
  });

  @override
  _RootPageState createState() => _RootPageState();
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
            isStaff: widget.isStaff,
            isAuthenticated: widget.isAuthenticated,
            username: widget.username,  // Add this
          ),
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
            isStaff: widget.isStaff,
            isAuthenticated: widget.isAuthenticated,
            username: widget.username,  // Add this
          ),
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

    // Check authentication requirements
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
      body: IndexedStack(
        index: _selectedIndex,
        children: menuItems.map<Widget>((item) => item['screen'] as Widget).toList(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: SizedBox(
            height: 60,
            child: BottomNavigationBar(
              items: menuItems.map((item) => BottomNavigationBarItem(
                icon: Icon(item['icon']),
                label: item['title'],
                activeIcon: Icon(item['icon']),
              )).toList(),
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.grey[400],
              unselectedItemColor: Colors.grey[800],
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.black,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              selectedIconTheme: const IconThemeData(size: 24),
              unselectedIconTheme: const IconThemeData(size: 20),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }
}