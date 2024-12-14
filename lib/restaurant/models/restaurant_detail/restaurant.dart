class Restaurant {
  String? name;
  String? kecamatan;
  String? location;

  Restaurant({this.name, this.kecamatan, this.location});

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        name: json['name'] as String?,
        kecamatan: json['kecamatan'] as String?,
        location: json['location'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'kecamatan': kecamatan,
        'location': location,
      };
}
