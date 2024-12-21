import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
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
    super.key,
    required this.minPriceController,
    required this.maxPriceController,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.kecamatans,
    required this.selectedKecamatan,
    required this.onKecamatanSelected,
    required this.onApplyFilters,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _currentCategory;
  late String _currentKecamatan;

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.selectedCategory;
    _currentKecamatan = widget.selectedKecamatan;
  }

  @override
  Widget build(BuildContext context) {
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
            children: widget.categories.map((category) {
              return FilterChip(
                label: Text(category),
                selected: _currentCategory == category,
                selectedColor: Colors.black,
                onSelected: (selected) {
                  setState(() {
                    _currentCategory = selected ? category : 'all';
                  });
                  widget.onCategorySelected(selected ? category : 'all');
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

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
            children: widget.kecamatans.map((kecamatan) {
              return FilterChip(
                label: Text(kecamatan),
                selected: _currentKecamatan == kecamatan,
                selectedColor: Colors.black,
                onSelected: (selected) {
                  setState(() {
                    _currentKecamatan = selected ? kecamatan : 'all';
                  });
                  widget.onKecamatanSelected(selected ? kecamatan : 'all');
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

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
                  controller: widget.minPriceController,
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
                  controller: widget.maxPriceController,
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
                widget.onApplyFilters();
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
  }
}
