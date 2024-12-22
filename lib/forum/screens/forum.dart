// import 'package:flutter/material.dart';
// import 'article.dart';
// import 'qna.dart';

// class ForumPage extends StatefulWidget {
//   const ForumPage({super.key});

//   @override
//   State<ForumPage> createState() => _ForumPageState();
// }

// class _ForumPageState extends State<ForumPage> {
//   int _selectedIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           decoration: const BoxDecoration(
//             color: Colors.white,  // Ensure white background
//             border: Border(
//               bottom: BorderSide(
//                 color: Colors.grey,
//                 width: 0.5,
//               ),
//             ),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               _buildTab('Articles', 0),
//               const SizedBox(width: 32),
//               _buildTab('Questions', 1),
//             ],
//           ),
//         ),
//         Expanded(
//           child: Container(
//             color: Colors.white,  // Ensure white background
//             child: _selectedIndex == 0 
//               ? const ArticleListPage()
//               : const QnaListPage(),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTab(String title, int index) {
//     final isSelected = _selectedIndex == index;
//     return InkWell(
//       onTap: () {
//         setState(() {
//           _selectedIndex = index;
//         });
//       },
//       child: Column(
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               color: isSelected ? Colors.black : Colors.grey,
//               fontSize: 16,
//               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Container(
//             height: 2,
//             width: 100,
//             color: isSelected ? Colors.black : Colors.transparent,
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'article.dart';
// import 'qna.dart';

// class ForumPage extends StatefulWidget {
//   const ForumPage({super.key});

//   @override
//   State<ForumPage> createState() => _ForumPageState();
// }

// class _ForumPageState extends State<ForumPage> {
//   int _selectedIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background Image
//           Positioned.fill(
//             child: Image.network(
//               'https://southfeast-production.up.railway.app/static/image/v19_292.png',
//               fit: BoxFit.cover,
//             ),
//           ),
//           // Content on Top
//           Column(
//             children: [
//               Expanded(
//                 child: Center(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Text(
//                         'Culinary Insight',
//                         style: TextStyle(
//                           fontSize: 36,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                           fontFamily: 'Cursive', // Customize font style
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Get the latest scoop on South Jakarta culinary world.',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.white.withOpacity(0.8),
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 32),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           ElevatedButton(
//                             onPressed: () {
//                               setState(() {
//                                 _selectedIndex = 0;
//                               });
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.white,
//                               foregroundColor: Colors.black,
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 24, vertical: 12),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             child: const Text('See Articles'),
//                           ),
//                           const SizedBox(width: 16),
//                           ElevatedButton(
//                             onPressed: () {
//                               setState(() {
//                                 _selectedIndex = 1;
//                               });
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.white,
//                               foregroundColor: Colors.black,
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 24, vertical: 12),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             child: const Text('See Q&A'),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               // Bottom Section (Tabs)
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 decoration: const BoxDecoration(
//                   color: Colors.white, // Ensure white background
//                   border: Border(
//                     top: BorderSide(
//                       color: Colors.grey,
//                       width: 0.5,
//                     ),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildTab('Articles', 0),
//                     const SizedBox(width: 32),
//                     _buildTab('Questions', 1),
//                   ],
//                 ),
//               ),
//               // Dynamic Content
//               Expanded(
//                 child: Container(
//                   color: Colors.white,
//                   child: _selectedIndex == 0
//                       ? const ArticleListPage()
//                       : const QnaListPage(),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTab(String title, int index) {
//     final isSelected = _selectedIndex == index;
//     return InkWell(
//       onTap: () {
//         setState(() {
//           _selectedIndex = index;
//         });
//       },
//       child: Column(
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               color: isSelected ? Colors.black : Colors.grey,
//               fontSize: 16,
//               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Container(
//             height: 2,
//             width: 100,
//             color: isSelected ? Colors.black : Colors.transparent,
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'article.dart';
import 'qna.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  bool _isIntroVisible = true; // Default layar intro
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isIntroVisible
          ? Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: Image.network(
                    'https://southfeast-production.up.railway.app/static/image/v19_292.png',
                    fit: BoxFit.cover,
                  ),
                ),
                // Intro Content
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Culinary Insight',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Cursive',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Get the latest scoop on South Jakarta culinary world.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // Buttons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildCustomButton(
                            text: 'See Articles',
                            onPressed: () {
                              setState(() {
                                _isIntroVisible = false;
                                _selectedIndex = 0;
                              });
                            },
                          ),
                          const SizedBox(width: 16),
                          _buildCustomButton(
                            text: 'See Q&A',
                            onPressed: () {
                              setState(() {
                                _isIntroVisible = false;
                                _selectedIndex = 1;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                // Tabs for Articles and Questions
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Colors.white, // Ensure white background
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTab('Articles', 0),
                      const SizedBox(width: 32),
                      _buildTab('Questions', 1),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: _selectedIndex == 0
                        ? const ArticleListPage()
                        : const QnaListPage(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCustomButton({required String text, required VoidCallback onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: const BorderSide(color: Colors.white), // Border putih
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Tombol oval
        ),
        foregroundColor: Colors.white, // Warna teks putih
        backgroundColor: Colors.black.withOpacity(0.5), // Transparan hitam
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 2,
            width: 100,
            color: isSelected ? Colors.black : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
