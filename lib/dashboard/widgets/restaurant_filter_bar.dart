
import 'package:flutter/material.dart';

class RestaurantFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final List<String> kecamatans;
  final String selectedKecamatan;
  final Function(String) onKecamatanSelected;
  final Function(String) onSearchSubmitted;

  const RestaurantFilterBar({
    Key? key,
    required this.searchController,
    required this.kecamatans,
    required this.selectedKecamatan,
    required this.onKecamatanSelected,
    required this.onSearchSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search restaurants...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: onSearchSubmitted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.location_city, color: Colors.grey[800]),
              onSelected: onKecamatanSelected,
              itemBuilder: (context) {
                return kecamatans.map((kecamatan) {
                  return PopupMenuItem(
                    value: kecamatan,
                    child: Text(kecamatan),
                  );
                }).toList();
              },
            ),
          ),
        ],
      ),
    );
  }
}