

// class RestaurantResponse {
//   final List<Restaurant> results;
//   final int currentPage;
//   final bool hasNext;
//   final List<String> kecamatans;

//   RestaurantResponse({
//     required this.results,
//     required this.currentPage,
//     required this.hasNext,
//     required this.kecamatans,
//   });

//   factory RestaurantResponse.fromMap(Map<String, dynamic> map) {
//     return RestaurantResponse(
//       results: List<Restaurant>.from(
//           map['results']?.map((x) => Restaurant.fromMap(x)) ?? []),
//       currentPage: map['current_page'] ?? 1,
//       hasNext: map['has_next'] ?? false,
//       kecamatans: List<String>.from(map['kecamatans'] ?? []),
//     );
//   }
// }

// class Restaurant {
//   final int id;
//   final String name;
//   final String kecamatan;
//   final String location;
//   final String image;
//   final double minPrice;
//   final double maxPrice;

//   Restaurant({
//     required this.id,
//     required this.name,
//     required this.kecamatan,
//     required this.location,
//     required this.image,
//     required this.minPrice,
//     required this.maxPrice,
//   });

//   factory Restaurant.fromMap(Map<String, dynamic> map) {
//     return Restaurant(
//       id: map['id']?.toInt() ?? 0,
//       name: map['name'] ?? '',
//       kecamatan: map['kecamatan'] ?? '',
//       location: map['location'] ?? '',
//       image: map['image'] ?? '',
//       minPrice: double.parse(map['min_price']?.toString() ?? '0'),
//       maxPrice: double.parse(map['max_price']?.toString() ?? '0'),
//     );
//   }
// }
