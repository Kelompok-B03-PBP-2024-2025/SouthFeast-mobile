import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class ReservationCreateScreen extends StatefulWidget {
  final String restaurantName;
  final int restaurantId; // Tambahkan restaurant ID
  final int? selectedFoodId;
  final String? selectedFoodName;

  const ReservationCreateScreen({
    Key? key,
    required this.restaurantName,
    required this.restaurantId, // Tambahkan parameter ini
    this.selectedFoodId,
    this.selectedFoodName,
  }) : super(key: key);

  @override
  State<ReservationCreateScreen> createState() => _ReservationCreateScreenState();
}

class _ReservationCreateScreenState extends State<ReservationCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _numberOfPeople = 1;
  bool _isLoading = false;
  List<Map<String, dynamic>> _availableFoods = [];
  int? _selectedFoodId;
  String? _selectedFoodName;

  @override
  void initState() {
    super.initState();
    _selectedFoodId = widget.selectedFoodId;
    _selectedFoodName = widget.selectedFoodName;
    _fetchAvailableFoods();
  }

  Future<void> _fetchAvailableFoods() async {
    final request = context.read<CookieRequest>();
    try {
      // Menggunakan endpoint yang sudah ada
      final response = await request.get(
        'http://southfeast-production.up.railway.app/restaurant/get/${widget.restaurantId}/'
      );
      
      // Mengambil daftar menu dari response
      if (response['menus'] != null) {
        setState(() {
          _availableFoods = List<Map<String, dynamic>>.from(response['menus']);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading foods: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final request = context.read<CookieRequest>();

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final timeStr = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

      // Menggunakan endpoint create_reservation yang sudah ada
      final response = await request.post(
        'http://southfeast-production.up.railway.app/restaurant/create-reservation/${widget.restaurantId}/',
        jsonEncode({
          'date': dateStr,
          'time': timeStr,
          'number_of_people': _numberOfPeople,
          'food_id': _selectedFoodId,
        }),
      );

      if (mounted) {
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reservation created successfully!')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Failed to create reservation')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating reservation: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make a Reservation'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Restaurant Name Display
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Restaurant',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.restaurantName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Food Selection
              // DropdownButtonFormField<int>(
              //   value: _selectedFoodId,
              //   decoration: const InputDecoration(
              //     labelText: 'Select Food',
              //     border: OutlineInputBorder(),
              //   ),
              //   items: _availableFoods.map((food) {
              //     return DropdownMenuItem<int>(
              //       value: food['id'],
              //       child: Text(food['name']),
              //     );
              //   }).toList(),
              //   onChanged: (value) {
              //     setState(() {
              //       _selectedFoodId = value;
              //       _selectedFoodName = _availableFoods
              //           .firstWhere((food) => food['id'] == value)['name'];
              //     });
              //   },
              //   validator: (value) {
              //     if (value == null) return 'Please select a food';
              //     return null;
              //   },
              // ),
              const SizedBox(height: 16),

              // Date Selection
              ListTile(
                title: const Text('Reservation Date'),
                subtitle: Text(
                  _selectedDate == null
                      ? 'Select date'
                      : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 16),

              // Time Selection
              ListTile(
                title: const Text('Reservation Time'),
                subtitle: Text(
                  _selectedTime == null
                      ? 'Select time'
                      : _selectedTime!.format(context),
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context),
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 16),

              // Number of People
              Row(
                children: [
                  const Text('Number of People'),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (_numberOfPeople > 1) {
                        setState(() => _numberOfPeople--);
                      }
                    },
                  ),
                  Text(
                    _numberOfPeople.toString(),
                    style: const TextStyle(fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() => _numberOfPeople++);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReservation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Confirm Reservation',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}