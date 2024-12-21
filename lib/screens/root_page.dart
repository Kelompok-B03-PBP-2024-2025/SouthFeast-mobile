import 'package:flutter/material.dart';
import 'package:southfeast_mobile/authentication/screens/login.dart';  // Add this import
import '../widgets/app_bar.dart';
import '../widgets/left_drawer.dart';  // Add this import
import '../widgets/custom_bottom_nav.dart';
import 'package:southfeast_mobile/config/menu_config.dart';
import 'package:southfeast_mobile/dashboard/screens/dashboard.dart'; // Add this import

class RootPage extends StatefulWidget {
  final bool isStaff;
  final bool isAuthenticated;
  final int initialIndex;
  final String? username;
  final int? userID;  // Add this
  final bool showRestaurants; // Add this parameter

  const RootPage({
    super.key,
    required this.isStaff,
    required this.isAuthenticated,
    this.initialIndex = 0,  // Add this parameter with a default value of 0
    this.username,  // Add this
    this.showRestaurants = false, // Add default value
    this.userID
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
    final menuItems = MenuConfig.getMenuItems(
      isStaff: widget.isStaff,
      isAuthenticated: widget.isAuthenticated,
      username: widget.username,
    );

    // If showRestaurants is true, modify the DashboardPage to show restaurants
    if (widget.showRestaurants && widget.isStaff) {
      final dashboardIndex = menuItems.indexWhere((item) => item['title'] == 'Dashboard');
      if (dashboardIndex != -1) {
        menuItems[dashboardIndex]['screen'] = DashboardPage(initialShowRestaurants: true);
      }
    }

    return menuItems;
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