import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:southfeast_mobile/reservation/models/reservation.dart';
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
    _fetchReservations();
  }

  Future<void> _fetchReservations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'http://localhost:8000/restaurant/show-json-reservations/',
      );

      if (mounted) {
        setState(() {
          _reservations = List<Map<String, dynamic>>.from(response['reservations']);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading reservations: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reservations'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchReservations,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _reservations.isEmpty
                    ? const Center(
                        child: Text('No reservations found'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _reservations.length,
                        itemBuilder: (context, index) {
                          final reservation = _reservations[index];
                          final reservationDate =
                              DateTime.parse(reservation['reservation_date']);
                          final reservationTime = TimeOfDay(
                            hour: int.parse(
                                reservation['reservation_time'].split(':')[0]),
                            minute: int.parse(
                                reservation['reservation_time'].split(':')[1]),
                          );

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: InkWell(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReservationDetailScreen(
                                      reservation: reservation,
                                    ),
                                  ),
                                );
                                
                                // Refresh list if reservation was modified or deleted
                                if (result == true) {
                                  _fetchReservations();
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
                                            reservation['restaurant_name'],
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
                                                reservation['status']),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            reservation['status'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on,
                                            size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          reservation['restaurant_location'],
                                          style:
                                              const TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          DateFormat('MMM dd, yyyy')
                                              .format(reservationDate),
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
                                          Text(reservation['food_name']),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
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
}

// import 'package:flutter/material.dart';
// import 'package:pbp_django_auth/pbp_django_auth.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import 'package:southfeast_mobile/reservation/models/reservation.dart';

// class MyReservationsPage extends StatefulWidget {
//   const MyReservationsPage({Key? key}) : super(key: key);

//   @override
//   State<MyReservationsPage> createState() => _MyReservationsPageState();
// }

// class _MyReservationsPageState extends State<MyReservationsPage> {
//   List<Reservation> _reservations = [];
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchReservations();
//   }

//   Future<void> _fetchReservations() async {
//     setState(() => _isLoading = true);
//     final request = context.read<CookieRequest>();
    
//     try {
//       final response = await request.get(
//         'https://southfeast-production.up.railway.app/reservation/list/',
//       );
      
//       setState(() {
//         _reservations = (response['reservations'] as List)
//             .map((json) => Reservation.fromJson(json))
//             .toList();
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Error fetching reservations')),
//         );
//       }
//     }
//   }

//   Future<void> _cancelReservation(int reservationId) async {
//     final request = context.read<CookieRequest>();
    
//     try {
//       final response = await request.post(
//         'https://southfeast-production.up.railway.app/reservation/cancel/',
//         {'reservation_id': reservationId.toString()},
//       );
      
//       if (response['status'] == 'success') {
//         _fetchReservations();
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Reservation cancelled successfully')),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Error cancelling reservation')),
//         );
//       }
//     }
//   }

//   Widget _buildReservationCard(Reservation reservation) {
//     final canCancel = reservation.status == 'active' &&
//         reservation.reservationDate.isAfter(DateTime.now());

//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         reservation.foodName,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(reservation.restaurantName),
//                     ],
//                   ),
//                 ),
//                 if (canCancel)
//                   TextButton(
//                     onPressed: () => _cancelReservation(reservation.id),
//                     child: const Text(
//                       'Cancel',
//                       style: TextStyle(color: Colors.red),
//                     ),
//                   ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Date: ${DateFormat('yyyy-MM-dd').format(reservation.reservationDate)} at ${reservation.reservationTime}',
//             ),
//             Text('People: ${reservation.numberOfPeople}'),
//             const SizedBox(height: 4),
//             Text(
//               'Status: ${reservation.status.toUpperCase()}',
//               style: TextStyle(
//                 color: reservation.status == 'active'
//                     ? Colors.green
//                     : reservation.status == 'cancelled'
//                         ? Colors.red
//                         : Colors.grey,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBody() {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_reservations.isEmpty) {
//       return const Center(
//         child: Text(
//           'No reservations found',
//           style: TextStyle(fontSize: 16),
//         ),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: _fetchReservations,
//       child: ListView.builder(
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         itemCount: _reservations.length,
//         itemBuilder: (context, index) => _buildReservationCard(_reservations[index]),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Reservations'),
//         backgroundColor: Colors.black,
//       ),
//       body: _buildBody(),
//     );
//   }
// }