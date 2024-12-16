import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:southfeast_mobile/authentication/screens/login.dart';

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isAuthenticated;
  final Function() onAuthStateChanged;

  const GlobalAppBar({
    super.key,
    required this.isAuthenticated,
    required this.onAuthStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return AppBar(
      // Add leading drawer icon
      leading: IconButton(
        icon: const Icon(
          Icons.menu,
          color: Colors.white,
        ),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      title: const Center(
        child: Text(
          'SouthFeast',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black,
      actions: [
        IconButton(
          icon: Icon(
            isAuthenticated ? Icons.logout : Icons.login,
            color: Colors.white,
          ),
          onPressed: () async {
            if (isAuthenticated) {
              try {
                // final response = await request
                //     .logout("http://10.0.2.2:8000/auth/api/logout/");
                // String message = response["message"];
                final response = await request
                    .logout("https://southfeast-production.up.railway.app/auth/api/logout/");
                String message = response["message"];
                if (context.mounted) {
                  if (response['status']) {
                    String uname = response["username"];
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("$message Sampai jumpa, $uname."),
                    ));
                    onAuthStateChanged();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout failed: $e'),
                    ),
                  );
                }
              }
            } else {
              Navigator.pushNamed(context, '/login');
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
