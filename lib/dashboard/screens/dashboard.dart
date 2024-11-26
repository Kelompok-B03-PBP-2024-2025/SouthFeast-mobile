// lib/screens/dashboard_page.dart
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.dashboard, size: 64),
          SizedBox(height: 16),
          Text('Dashboard Content'),
        ],
      ),
    );
  }
}

