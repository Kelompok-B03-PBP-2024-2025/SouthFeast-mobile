import 'package:flutter/material.dart';
// import 'package:southfeast_mobile/product/screens/product.dart';
// import 'package:southfeast_mobile/forum/screens/forum.dart';
// import 'package:southfeast_mobile/review/screens/review.dart';
// import 'package:southfeast_mobile/wishlist/screens/wishlist.dart';
// import 'package:southfeast_mobile/dashboard/screens/dashboard.dart';
// import 'package:southfeast_mobile/restaurant/screens/restaurant.dart';
import 'package:southfeast_mobile/authentication/screens/login.dart';
// import 'package:southfeast_mobile/screens/homepage.dart';
import 'package:southfeast_mobile/screens/root_page.dart';

class LeftDrawer extends StatelessWidget {
  final bool isStaff;
  final bool isAuthenticated;

  const LeftDrawer({
    super.key,
    required this.isStaff,
    required this.isAuthenticated,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SouthFeast',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Get Lost. Find South Jakarta.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home Page'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RootPage(
                    isStaff: isStaff,
                    isAuthenticated: isAuthenticated,
                  ),
                ),
              );
            },
          ),
          if (!isStaff) ...[
            ListTile(
              leading: const Icon(Icons.shopping_cart_outlined),
              title: const Text('Product'),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RootPage(
                    isStaff: isStaff,
                    isAuthenticated: isAuthenticated,
                    initialIndex: 1, // Catalog index
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_outlined),
              title: const Text('Restaurant'),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RootPage(
                    isStaff: isStaff,
                    isAuthenticated: isAuthenticated,
                    initialIndex: 2, // Restaurant index
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.favorite_outline),
              title: const Text('Wishlist'),
              onTap: () {
                if (!isAuthenticated) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                  return;
                }
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RootPage(
                      isStaff: isStaff,
                      isAuthenticated: isAuthenticated,
                      initialIndex: 3, // Wishlist index
                    ),
                  ),
                );
              },
            ),
          ],
          if (isStaff) ...[
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              onTap: () {
                if (!isAuthenticated) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                  return;
                }
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RootPage(
                      isStaff: isStaff,
                      isAuthenticated: isAuthenticated,
                      initialIndex: 1, // Dashboard index for staff
                    ),
                  ),
                );
              },
            ),
          ],
          ListTile(
            leading: const Icon(Icons.forum_outlined),
            title: const Text('Forum'),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => RootPage(
                  isStaff: isStaff,
                  isAuthenticated: isAuthenticated,
                  initialIndex: isStaff ? 3 : 4, // Forum index
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.rate_review_outlined),
            title: const Text('Review'),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => RootPage(
                  isStaff: isStaff,
                  isAuthenticated: isAuthenticated,
                  initialIndex: isStaff ? 2 : 5, // Review index
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
