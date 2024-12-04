import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class MakananForm extends StatefulWidget {
  const MakananForm({super.key});

  @override
  State<MakananForm> createState() => _MakananFormState();
}

class _MakananFormState extends State<MakananForm> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _description = '';
  double  _price = 0;
  String _image = '';
  String _category = '';
  String _restaurant_name = '';
  String _kecamatan = '';
  String _location = '';
  bool _isLoading = false;

  // Add these lists at the top of the class
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

  // Helper method untuk membuat InputDecoration
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
        title: const Text('Add Food Item'),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white
        ),
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
                          decoration: _buildDecoration('Name', 'Enter food name'),
                          onChanged: (value) => _name = value,
                          validator: (value) => value!.isEmpty ? "Name cannot be empty!" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: _buildDecoration('Description', 'Enter food description'),
                          onChanged: (value) => _description = value,
                          validator: (value) => value!.isEmpty ? "Description cannot be empty!" : null,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: _buildDecoration('Price', 'Enter price'),
                          onChanged: (value) => _price = double.tryParse(value) ?? 0,
                          keyboardType: TextInputType.number,
                          validator: (value) => value!.isEmpty ? "Price cannot be empty!" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: _buildDecoration('Image URL', 'Enter image URL'),
                          onChanged: (value) => _image = value,
                          validator: (value) => value!.isEmpty ? "Image URL cannot be empty!" : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          decoration: _buildDecoration('Category', 'Select category'),
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
                          validator: (value) => value == null ? "Please select a category" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: _buildDecoration('Restaurant Name', 'Enter restaurant name'),
                          onChanged: (value) => _restaurant_name = value,
                          validator: (value) => value!.isEmpty ? "Restaurant name cannot be empty!" : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          decoration: _buildDecoration('Kecamatan', 'Select kecamatan'),
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
                          validator: (value) => value == null ? "Please select a kecamatan" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: _buildDecoration('Location', 'Enter location'),
                          onChanged: (value) => _location = value,
                          validator: (value) => value!.isEmpty ? "Location cannot be empty!" : null,
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
                                          'http://10.0.2.2:8000/dashboard/create-makanan-flutter/',
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
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              title: const Text('Success'),
                                              content: const Text('Food item added successfully!'),
                                              actions: [
                                                TextButton(
                                                  child: const Text('OK'),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Error'),
                                            content: Text(e.toString()),
                                            actions: [
                                              TextButton(
                                                child: const Text('OK'),
                                                onPressed: () => Navigator.pop(context),
                                              ),
                                            ],
                                          ),
                                        );
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
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Save',
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

