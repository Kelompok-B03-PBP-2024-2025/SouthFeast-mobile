// // import 'dart:convert';

// // import 'package:collection/collection.dart';


// // class Restaurant {
// //   final List<Restaurant>? restaurants;
// //   final List<String>? kecamatans;
// //   final dynamic selectedKecamatan;
// //   final String? searchQuery;
// //   final int? totalPages;
// //   final int? currentPage;
// //   final bool? hasPrevious;
// //   final bool? hasNext;

// //   const Restaurant({
// //     this.restaurants,
// //     this.kecamatans,
// //     this.selectedKecamatan,
// //     this.searchQuery,
// //     this.totalPages,
// //     this.currentPage,
// //     this.hasPrevious,
// //     this.hasNext,
// //   });

// //   @override
// //   String toString() {
// //     return 'Restaurant(restaurants: $restaurants, kecamatans: $kecamatans, selectedKecamatan: $selectedKecamatan, searchQuery: $searchQuery, totalPages: $totalPages, currentPage: $currentPage, hasPrevious: $hasPrevious, hasNext: $hasNext)';
// //   }

// //   factory Restaurant.fromMap(Map<String, dynamic> data) => Restaurant(
// //         restaurants: (data['restaurants'] as List<dynamic>?)
// //             ?.map((e) => Restaurant.fromMap(e as Map<String, dynamic>))
// //             .toList(),
// //         kecamatans: data['kecamatans'] as List<String>?,
// //         selectedKecamatan: data['selected_kecamatan'] as dynamic,
// //         searchQuery: data['search_query'] as String?,
// //         totalPages: data['total_pages'] as int?,
// //         currentPage: data['current_page'] as int?,
// //         hasPrevious: data['has_previous'] as bool?,
// //         hasNext: data['has_next'] as bool?,
// //       );

// //   Map<String, dynamic> toMap() => {
// //         'restaurants': restaurants?.map((e) => e.toMap()).toList(),
// //         'kecamatans': kecamatans,
// //         'selected_kecamatan': selectedKecamatan,
// //         'search_query': searchQuery,
// //         'total_pages': totalPages,
// //         'current_page': currentPage,
// //         'has_previous': hasPrevious,
// //         'has_next': hasNext,
// //       };

// //   /// `dart:convert`
// //   ///
// //   /// Parses the string and returns the resulting Json object as [Restaurant].
// //   factory Restaurant.fromJson(String data) {
// //     return Restaurant.fromMap(json.decode(data) as Map<String, dynamic>);
// //   }

// //   /// `dart:convert`
// //   ///
// //   /// Converts [Restaurant] to a JSON string.
// //   String toJson() => json.encode(toMap());

// //   @override
// //   bool operator ==(Object other) {
// //     if (identical(other, this)) return true;
// //     if (other is! Restaurant) return false;
// //     final mapEquals = const DeepCollectionEquality().equals;
// //     return mapEquals(other.toMap(), toMap());
// //   }

// //   @override
// //   int get hashCode =>
// //       restaurants.hashCode ^
// //       kecamatans.hashCode ^
// //       selectedKecamatan.hashCode ^
// //       searchQuery.hashCode ^
// //       totalPages.hashCode ^
// //       currentPage.hashCode ^
// //       hasPrevious.hashCode ^
// //       hasNext.hashCode;
// // }

// // restaurant.dart
// import 'dart:convert';
// import 'restaurant_result.dart';

// class Restaurant {
//   List<RestaurantResult>? results;
//   int? totalPages;
//   int? currentPage;
//   bool? hasPrevious;
//   bool? hasNext;

//   Restaurant({
//     this.results,
//     this.totalPages,
//     this.currentPage,
//     this.hasPrevious,
//     this.hasNext,
//   });

//   factory Restaurant.fromMap(Map<String, dynamic> data) => Restaurant(
//         results: (data['results'] as List<dynamic>?)
//             ?.map((e) => RestaurantResult.fromMap(e as Map<String, dynamic>))
//             .toList(),
//         totalPages: data['total_pages'] as int?,
//         currentPage: data['current_page'] as int?,
//         hasPrevious: data['has_previous'] as bool?,
//         hasNext: data['has_next'] as bool?,
//       );

//   Map<String, dynamic> toMap() => {
//         'results': results?.map((e) => e.toMap()).toList(),
//         'total_pages': totalPages,
//         'current_page': currentPage,
//         'has_previous': hasPrevious,
//         'has_next': hasNext,
//       };

//   factory Restaurant.fromJson(String data) {
//     return Restaurant.fromMap(json.decode(data) as Map<String, dynamic>);
//   }

//   String toJson() => json.encode(toMap());
// }
