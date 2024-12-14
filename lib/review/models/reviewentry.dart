// To parse this JSON data, do
//
//     final reviewEntry = reviewEntryFromJson(jsonString);

import 'dart:convert';

List<ReviewEntry> reviewEntryFromJson(String str) => List<ReviewEntry>.from(json.decode(str).map((x) => ReviewEntry.fromJson(x)));

String reviewEntryToJson(List<ReviewEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReviewEntry {
    int id;
    String menuItem;
    String user;
    String reviewText;
    double rating;
    String? reviewImage;
    DateTime createdAt;

    ReviewEntry({
        required this.id,
        required this.menuItem,
        required this.user,
        required this.reviewText,
        required this.rating,
        required this.reviewImage,
        required this.createdAt,
    });

    factory ReviewEntry.fromJson(Map<String, dynamic> json) => ReviewEntry(
        id: json["id"],
        menuItem: json["menu_item"],
        user: json["user"],
        reviewText: json["review_text"],
        rating: json["rating"]?.toDouble(),
        reviewImage: json["review_image"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "menu_item": menuItem,
        "user": user,
        "review_text": reviewText,
        "rating": rating,
        "review_image": reviewImage,
        "created_at": createdAt.toIso8601String(),
    };
}
