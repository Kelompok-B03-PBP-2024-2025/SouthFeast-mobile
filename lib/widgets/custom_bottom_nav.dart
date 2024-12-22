import 'package:flutter/material.dart';
import 'package:southfeast_mobile/authentication/screens/login.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems;
  final int selectedIndex;
  final Function(int) onTap;
  final bool isAuthenticated;
  final Function(BuildContext, Map<String, dynamic>) onAuthCheck;
  final double height;

  const CustomBottomNavigationBar({
    super.key,
    required this.menuItems,
    required this.selectedIndex,
    required this.onTap,
    required this.isAuthenticated,
    required this.onAuthCheck,
    this.height = 70,
  });

  void handleItemTap(BuildContext context, int index) {
    final selectedItem = menuItems[index];

    if (selectedItem['requiresAuth'] && !isAuthenticated) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(40),
        topRight: Radius.circular(40),
      ),
      child: Container(
        height: height,
        child: Theme(
          data: ThemeData(
            splashFactory: NoSplash.splashFactory,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            items: menuItems
                .map((item) => BottomNavigationBarItem(
                      icon: Icon(item['icon']),
                      label: item['title'],
                      activeIcon: Icon(item['icon']),
                    ))
                .toList(),
            currentIndex: selectedIndex,
            selectedItemColor: Colors.grey[400],
            unselectedItemColor: Colors.grey[800],
            onTap: (index) => handleItemTap(context, index),
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
    );
  }
}
