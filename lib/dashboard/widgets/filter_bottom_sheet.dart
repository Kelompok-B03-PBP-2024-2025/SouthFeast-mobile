
import 'package:flutter/material.dart';

class FilterBottomSheet extends StatelessWidget {
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final List<String> kecamatans;
  final String selectedKecamatan;
  final Function(String) onKecamatanSelected;
  final VoidCallback onApplyFilters;

  const FilterBottomSheet({
    Key? key,
    required this.minPriceController,
    required this.maxPriceController,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.kecamatans,
    required this.selectedKecamatan,
    required this.onKecamatanSelected,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),

              // Category Filter
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: categories.map((category) {
                  return FilterChip(
                    label: Text(category),
                    selected: selectedCategory == category,
                    selectedColor: Colors.black, // Change selected color to black
                    onSelected: (selected) {
                      setState(() {
                        onCategorySelected(selected ? category : 'all');
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Location Filter
              const Text(
                'Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: kecamatans.map((kecamatan) {
                  return FilterChip(
                    label: Text(kecamatan),
                    selected: selectedKecamatan == kecamatan,
                    selectedColor: Colors.black, // Change selected color to black
                    onSelected: (selected) {
                      setState(() {
                        onKecamatanSelected(selected ? kecamatan : 'all');
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Price Range
              const Text(
                'Price Range',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Min Price',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: maxPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Max Price',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onApplyFilters();
                  },
                  child: const Text(
                    'Apply Filter',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}