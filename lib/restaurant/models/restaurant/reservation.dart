import 'package:flutter/material.dart';

class Reservation {
  final int id;
  final int foodId;
  final String foodName;
  final String restaurantName;
  final DateTime reservationDate;
  final TimeOfDay reservationTime;
  final int numberOfPeople;
  final String status; // 'active', 'completed', 'cancelled'
  final DateTime createdAt;

  Reservation({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.restaurantName,
    required this.reservationDate,
    required this.reservationTime,
    required this.numberOfPeople,
    required this.status,
    required this.createdAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      foodId: json['food_id'],
      foodName: json['food_name'],
      restaurantName: json['restaurant_name'],
      reservationDate: DateTime.parse(json['reservation_date']),
      reservationTime: TimeOfDay(
        hour: int.parse(json['reservation_time'].split(':')[0]),
        minute: int.parse(json['reservation_time'].split(':')[1]),
      ),
      numberOfPeople: json['number_of_people'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}