import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
  final bool isStaff;
  final bool isAuthenticated;
  final String? username;  // Add this

  const MyHomePage({
    super.key,
    required this.isStaff,
    required this.isAuthenticated,
    this.username,  // Add this
  });

  @override
  Widget build(BuildContext context) {
    String welcomeMessage;

    if (isAuthenticated) {
      if (isStaff) {
        welcomeMessage = 'Welcome, Staff $username!';
      } else {
        welcomeMessage = 'Welcome, $username!';
      }
    } else {
      welcomeMessage = 'Welcome, Guest! Please log in.';
    }

    return Scaffold(
      body: Center(
        child: Text(welcomeMessage),
      ),
    );
  }
}