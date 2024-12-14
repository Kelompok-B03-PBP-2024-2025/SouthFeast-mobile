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
import '../widgets/custom_bottom_nav.dart';
import 'package:southfeast_mobile/config/menu_config.dart';

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
    return MenuConfig.getMenuItems(
      isStaff: widget.isStaff,
      isAuthenticated: widget.isAuthenticated,
      username: widget.username,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = _getMenuItems();

    return Scaffold(
      extendBody: true,
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
      bottomNavigationBar: CustomBottomNavigationBar(
        menuItems: menuItems,
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
        isAuthenticated: isAuthenticated,
        onAuthCheck: (context, item) {
          if (item['requiresAuth'] && !isAuthenticated) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          }
        },
      ),
    );
  }
}