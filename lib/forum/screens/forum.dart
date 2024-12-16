import 'package:flutter/material.dart';

class ForumPage extends StatelessWidget {
  const ForumPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.forum, size: 64),
          SizedBox(height: 16),
          Text('Forum Content'),
        ],
      ),
    );
  }
}
