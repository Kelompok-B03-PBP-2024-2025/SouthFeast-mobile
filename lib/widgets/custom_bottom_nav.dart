
import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems;
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.menuItems,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Theme(
        data: ThemeData(
          splashFactory: NoSplash.splashFactory,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          items: menuItems.map((item) => BottomNavigationBarItem(
            icon: Icon(item['icon']),
            label: item['title'],
            activeIcon: Icon(item['icon']),
          )).toList(),
          currentIndex: selectedIndex,
          selectedItemColor: Colors.grey[400],
          unselectedItemColor: Colors.grey[800],
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.black,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedIconTheme: const IconThemeData(size: 24),
          unselectedIconTheme: const IconThemeData(size: 20),
          elevation: 0,
        ),
      ),
    );
  }
}