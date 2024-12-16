import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:southfeast_mobile/restaurant/models/restaurant/reservation.dart';

class MyReservationsPage extends StatefulWidget {
  const MyReservationsPage({Key? key}) : super(key: key);

  @override
  State<MyReservationsPage> createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends State<MyReservationsPage> {
  List<Reservation> _reservations = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  Future<void> _fetchReservations() async {
    setState(() => _isLoading = true);
    final request = context.read<CookieRequest>();
    
    try {
      final response = await request.get(
        'https://southfeast-production.up.railway.app/reservation/list/',
      );
      
      setState(() {
        _reservations = (response['reservations'] as List)
            .map((json) => Reservation.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error fetching reservations')),
        );
      }
    }
  }

  Future<void> _cancelReservation(int reservationId) async {
    final request = context.read<CookieRequest>();
    
    try {
      final response = await request.post(
        'https://southfeast-production.up.railway.app/reservation/cancel/',
        {'reservation_id': reservationId.toString()},
      );
      
      if (response['status'] == 'success') {
        _fetchReservations();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reservation cancelled successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error cancelling reservation')),
        );
      }
    }
  }

  Widget _buildReservationCard(Reservation reservation) {
    final canCancel = reservation.status == 'active' &&
        reservation.reservationDate.isAfter(DateTime.now());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.foodName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(reservation.restaurantName),
                    ],
                  ),
                ),
                if (canCancel)
                  TextButton(
                    onPressed: () => _cancelReservation(reservation.id),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${DateFormat('yyyy-MM-dd').format(reservation.reservationDate)} at ${reservation.reservationTime}',
            ),
            Text('People: ${reservation.numberOfPeople}'),
            const SizedBox(height: 4),
            Text(
              'Status: ${reservation.status.toUpperCase()}',
              style: TextStyle(
                color: reservation.status == 'active'
                    ? Colors.green
                    : reservation.status == 'cancelled'
                        ? Colors.red
                        : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reservations.isEmpty) {
      return const Center(
        child: Text(
          'No reservations found',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchReservations,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _reservations.length,
        itemBuilder: (context, index) => _buildReservationCard(_reservations[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reservations'),
        backgroundColor: Colors.black,
      ),
      body: _buildBody(),
    );
  }
}