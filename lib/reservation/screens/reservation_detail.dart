import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class ReservationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> reservation;

  const ReservationDetailScreen({
    Key? key,
    required this.reservation,
  }) : super(key: key);

  @override
  State<ReservationDetailScreen> createState() => _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  bool _isLoading = false;

  Future<void> _deleteReservation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Reservation'),
        content: const Text('Are you sure you want to cancel this reservation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    final request = context.read<CookieRequest>();

    try {
      final response = await request.post(
        'http://southfeast-production.up.railway.app/restaurant/cancel-reservation/${widget.reservation['id']}/',
        jsonEncode({}),
      );

      if (mounted) {
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reservation cancelled successfully')),
          );
          Navigator.pop(context, true); // Return true to indicate deletion
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Failed to cancel reservation')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cancelling reservation: $e')),
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
    final reservation = widget.reservation;
    final reservationDate = DateTime.parse(reservation['reservation_date']);
    final reservationTime = TimeOfDay(
      hour: int.parse(reservation['reservation_time'].split(':')[0]),
      minute: int.parse(reservation['reservation_time'].split(':')[1]),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation Detail'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reservation['restaurant_name'],
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16),
                              const SizedBox(width: 4),
                              Text(reservation['restaurant_location']),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Reservation Details Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reservation Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            'Date',
                            DateFormat('MMM dd, yyyy').format(reservationDate),
                            Icons.calendar_today,
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            'Time',
                            reservationTime.format(context),
                            Icons.access_time,
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            'Number of People',
                            reservation['number_of_people'].toString(),
                            Icons.people,
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            'Status',
                            reservation['status'],
                            Icons.info_outline,
                          ),
                          if (reservation['food_name'] != null) ...[
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              'Food Order',
                              reservation['food_name'],
                              Icons.restaurant,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to edit screen
                            // TODO: Implement edit navigation
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Reservation'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _deleteReservation,
                          icon: const Icon(Icons.cancel),
                          label: const Text('Cancel Reservation'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}