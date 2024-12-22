import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:southfeast_mobile/authentication/screens/login.dart';
import 'package:southfeast_mobile/reservation/screens/reservation_detail.dart';

class ReservationViewAllScreen extends StatefulWidget {
  const ReservationViewAllScreen({Key? key}) : super(key: key);

  @override
  State<ReservationViewAllScreen> createState() => _ReservationViewAllScreenState();
}

class _ReservationViewAllScreenState extends State<ReservationViewAllScreen> {
  List<Map<String, dynamic>> _reservations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchReservations();
    });
  }

  Future<void> _fetchReservations() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final request = context.read<CookieRequest>();
    
    try {
      // Check if user is logged in
      if (!request.loggedIn) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginApp()),
        );
        return;
      }

      final response = await request.get(
        'http://southfeast-production.up.railway.app/restaurant/show-json-reservations/',
      );

      if (!mounted) return;

      // Check if response is HTML (redirect to login)
      if (response is String && response.contains('<!DOCTYPE')) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginApp()),
        );
        return;
      }

      // Check if response is valid and contains reservations
      if (response is Map<String, dynamic> && response.containsKey('reservations')) {
        setState(() {
          _reservations = List<Map<String, dynamic>>.from(response['reservations']);
          _isLoading = false;
        });
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('Error fetching reservations: $e');
      if (!mounted) return;
      
      setState(() {
        _error = 'Unable to load reservations. Please try again later.';
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to load reservations. Please check your connection and try again.'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _fetchReservations,
          ),
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildReservationList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchReservations,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_reservations.isEmpty) {
      return const Center(
        child: Text('No reservations found'),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _reservations.length,
      itemBuilder: (context, index) {
        final reservation = _reservations[index];
        DateTime? reservationDate;
        TimeOfDay? reservationTime;

        try {
          reservationDate = DateTime.parse(reservation['reservation_date']);
          final timeParts = reservation['reservation_time'].split(':');
          reservationTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
        } catch (e) {
          print('Error parsing date/time: $e');
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () async {
              try {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ReservationDetailScreen(
                      reservation: reservation,
                    ),
                  ),
                );
                
                if (result == true && mounted) {
                  _fetchReservations();
                }
              } catch (e) {
                print('Error navigating to detail: $e');
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reservation['restaurant_name'] ?? 'Unknown Restaurant',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                              reservation['status'] ?? 'unknown'),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          reservation['status'] ?? 'Unknown',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (reservation['restaurant_location'] != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            reservation['restaurant_location'],
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(reservationDate),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(reservationTime.format(context)),
                    ],
                  ),
                  if (reservation['food_name'] != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.restaurant,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(reservation['food_name']),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Reservations'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _fetchReservations,
          child: _buildReservationList(),
        ),
      ),
    );
  }
}