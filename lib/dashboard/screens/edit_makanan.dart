import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:southfeast_mobile/dashboard/models/product/result.dart';

class EditMakananForm extends StatefulWidget {
  final Map<String, dynamic> makanan;

  const EditMakananForm({super.key, required this.makanan});

  @override
  State<EditMakananForm> createState() => _EditMakananFormState();
}

class _EditMakananFormState extends State<EditMakananForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late String _name;
  late String _description;
  late double _price;
  late String _image;
  late String _category;
  late String _restaurant_name;
  late String _kecamatan;
  late String _location;

  final List<String> kecamatanChoices = [
    "Kebayoran Lama",
    "Kebayoran Baru",
    "Cilandak",
    "Mampang Prapatan",
    "Jagakarsa",
    "Pancoran",
    "Pasar Minggu",
    "Pesanggrahan",
    "Setiabudi",
    "Tebet",
  ];

  final List<String> categoryChoices = [
    'Makanan Laut',
    'Makanan Tradisional',
    'Makanan Sehat',
    'Makanan Cepat Saji',
    'Makanan Penutup',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the form fields with existing data
    _name = widget.makanan['name'];
    _description = widget.makanan['description'];
    // Fix the price conversion
    _price = double.parse(widget.makanan['price'].toString());
    _image = widget.makanan['image'];
    _category = widget.makanan['category'];
    _restaurant_name = widget.makanan['restaurant_name'];
    _kecamatan = widget.makanan['kecamatan'];
    _location = widget.makanan['location'];
  }

  InputDecoration _buildDecoration(String label, String hint) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      filled: true,
      fillColor: Colors.white,
      // Styling normal state border
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: Colors.grey.shade400,
          width: 1.0,
        ),
      ),
      // Styling focused state border
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: Colors.black,
          width: 2.0,
        ),
      ),
      // Styling error state border
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.0,
        ),
      ),
      // Styling focused error state border
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2.0,
        ),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text('Edit Food Item'),
        titleTextStyle: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: _name,
                          decoration:
                              _buildDecoration('Name', 'Enter food name'),
                          onChanged: (value) => _name = value,
                          validator: (value) =>
                              value!.isEmpty ? "Name cannot be empty!" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: _description,
                          decoration: _buildDecoration(
                              'Description', 'Enter food description'),
                          onChanged: (value) => _description = value,
                          validator: (value) => value!.isEmpty
                              ? "Description cannot be empty!"
                              : null,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: _price.toString(),
                          decoration: _buildDecoration('Price', 'Enter price'),
                          onChanged: (value) =>
                              _price = double.tryParse(value) ?? 0,
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value!.isEmpty ? "Price cannot be empty!" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: _image,
                          decoration:
                              _buildDecoration('Image URL', 'Enter image URL'),
                          onChanged: (value) => _image = value,
                          validator: (value) => value!.isEmpty
                              ? "Image URL cannot be empty!"
                              : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          decoration:
                              _buildDecoration('Category', 'Select category'),
                          value: _category.isEmpty ? null : _category,
                          items: categoryChoices.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _category = newValue ?? '';
                            });
                          },
                          validator: (value) =>
                              value == null ? "Please select a category" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: _restaurant_name,
                          decoration: _buildDecoration(
                              'Restaurant Name', 'Enter restaurant name'),
                          onChanged: (value) => _restaurant_name = value,
                          validator: (value) => value!.isEmpty
                              ? "Restaurant name cannot be empty!"
                              : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          decoration:
                              _buildDecoration('Kecamatan', 'Select kecamatan'),
                          value: _kecamatan.isEmpty ? null : _kecamatan,
                          items: kecamatanChoices.map((String kecamatan) {
                            return DropdownMenuItem<String>(
                              value: kecamatan,
                              child: Text(kecamatan),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _kecamatan = newValue ?? '';
                            });
                          },
                          validator: (value) => value == null
                              ? "Please select a kecamatan"
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: _location,
                          decoration:
                              _buildDecoration('Location', 'Enter location'),
                          onChanged: (value) => _location = value,
                          validator: (value) => value!.isEmpty
                              ? "Location cannot be empty!"
                              : null,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() => _isLoading = true);

                                      try {
                                        final response = await request.postJson(
                                          // 'http://127.0.0.1:8000/dashboard/edit-makanan-flutter/${widget.makanan['id']}/',
                                          'https://southfeast-production.up.railway.app/dashboard/edit-makanan-flutter/${widget.makanan['id']}/',
                                          jsonEncode({
                                            'name': _name,
                                            'description': _description,
                                            'price': _price,
                                            'image': _image,
                                            'category': _category,
                                            'restaurant_name': _restaurant_name,
                                            'kecamatan': _kecamatan,
                                            'location': _location,
                                          }),
                                        );

                                        if (response['status'] == 'success') {
                                          if (context.mounted) {
                                            // Buat objek Result baru dari response
                                            final updatedResult = Result(
                                              id: widget.makanan['id'],
                                              name: _name,
                                              description: _description,
                                              price: _price.toString(),
                                              image: _image,
                                              category: _category,
                                              restaurantName: _restaurant_name,
                                              kecamatan: _kecamatan,
                                              location: _location,
                                            );

                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                title: const Text('Success'),
                                                content: const Text(
                                                    'Food item updated successfully!'),
                                                actions: [
                                                  TextButton(
                                                    child: const Text('OK'),
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          context); // tutup dialog
                                                      Navigator.pop(context,
                                                          updatedResult); // kembali ke detail dengan data baru
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Error'),
                                              content: Text(e.toString()),
                                              actions: [
                                                TextButton(
                                                  child: const Text('OK'),
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      } finally {
                                        setState(() => _isLoading = false);
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Update',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
