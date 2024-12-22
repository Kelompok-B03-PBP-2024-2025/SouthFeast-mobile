import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Restaurant {
  final int id;
  final String name;
  final String location;
  final String kecamatan;

  Restaurant({
    required this.id,
    required this.name,
    required this.location,
    required this.kecamatan,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      kecamatan: json['kecamatan'],
    );
  }
}

class Reservation {
  final int id;
  final Restaurant restaurant;
  final DateTime reservationDate;
  final TimeOfDay reservationTime;
  final int numberOfPeople;
  final DateTime createdAt;

  Reservation({
    required this.id,
    required this.restaurant,
    required this.reservationDate,
    required this.reservationTime,
    required this.numberOfPeople,
    required this.createdAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      restaurant: Restaurant.fromJson(json['restaurant']),
      reservationDate: DateTime.parse(json['reservation_date']),
      reservationTime: TimeOfDay(
        hour: int.parse(json['reservation_time'].split(':')[0]),
        minute: int.parse(json['reservation_time'].split(':')[1]),
      ),
      numberOfPeople: json['number_of_people'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurant_id': restaurant.id,
      'reservation_date': DateFormat('yyyy-MM-dd').format(reservationDate),
      'reservation_time': '${reservationTime.hour.toString().padLeft(2, '0')}:${reservationTime.minute.toString().padLeft(2, '0')}',
      'number_of_people': numberOfPeople,
    };
  }
}