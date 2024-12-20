import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class EditRestaurantForm extends StatefulWidget {
  final Map<String, dynamic> restaurant;

  const EditRestaurantForm({super.key, required this.restaurant});

  @override
  State<EditRestaurantForm> createState() => _EditRestaurantFormState();
}

class _EditRestaurantFormState extends State<EditRestaurantForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late String _name;
  late String _location;
  late String _kecamatan;

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

  @override
  void initState() {
    super.initState();
    _name = widget.restaurant['name'];
    _location = widget.restaurant['location'];
    _kecamatan = widget.restaurant['kecamatan'];
  }

  InputDecoration _buildDecoration(String label, String hint) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.black, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
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
        title: const Text('Edit Restaurant'),
        titleTextStyle: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Card(
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
                      decoration: _buildDecoration('Restaurant Name', 'Enter restaurant name'),
                      onChanged: (value) => _name = value,
                      validator: (value) => value!.isEmpty ? "Name cannot be empty!" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: _location,
                      decoration: _buildDecoration('Location', 'Enter location'),
                      onChanged: (value) => _location = value,
                      validator: (value) => value!.isEmpty ? "Location cannot be empty!" : null,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
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
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);
                            try {
                              final response = await request.postJson(
                                // 'http://127.0.0.1:8000/dashboard/edit-restaurant-flutter/${widget.restaurant['name']}/',
                                'https://southfeast-production.up.railway.app/dashboard/edit-restaurant-flutter/${widget.restaurant['name']}/',
                                jsonEncode({
                                  'name': _name,
                                  'location': _location,
                                  'kecamatan': _kecamatan,
                                }),
                              );

                              if (response['status'] == 'success') {
                                if (context.mounted) {
                                  // Return updated data
                                  final updatedData = {
                                    ...widget.restaurant,
                                    'name': _name,
                                    'location': _location,
                                    'kecamatan': _kecamatan,
                                  };
                                  Navigator.pop(context, updatedData);
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
                                        onPressed: () => Navigator.pop(context),
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
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Update',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
