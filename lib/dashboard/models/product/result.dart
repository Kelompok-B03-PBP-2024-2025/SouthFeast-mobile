import 'dart:convert';

class Result {
  int? id;
  String? name;
  String? description;
  String? price;
  String? category;
  String? kecamatan;
  String? image;
  String? restaurantName;
  String? location;

  Result({
    this.id,
    this.name,
    this.description,
    this.price,
    this.category,
    this.kecamatan,
    this.image,
    this.restaurantName,
    this.location,
  });

  factory Result.fromMap(Map<String, dynamic> data) => Result(
        id: data['id'] as int?,
        name: data['name'] as String?,
        description: data['description'] as String?,
        price: data['price'] as String?,
        category: data['category'] as String?,
        kecamatan: data['kecamatan'] as String?,
        image: data['image'] as String?,
        restaurantName: data['restaurant_name'] as String?,
        location: data['location'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'kecamatan': kecamatan,
        'image': image,
        'restaurant_name': restaurantName,
        'location': location,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Result].
  factory Result.fromJson(String data) {
    return Result.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Result] to a JSON string.
  String toJson() => json.encode(toMap());
}
