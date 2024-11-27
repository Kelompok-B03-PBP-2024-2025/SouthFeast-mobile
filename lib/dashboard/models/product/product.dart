import 'dart:convert';

import 'result.dart';

class Product {
  List<Result>? results;
  int? totalPages;
  int? currentPage;
  bool? hasPrevious;
  bool? hasNext;

  Product({
    this.results,
    this.totalPages,
    this.currentPage,
    this.hasPrevious,
    this.hasNext,
  });

  factory Product.fromMap(Map<String, dynamic> data) => Product(
        results: (data['results'] as List<dynamic>?)
            ?.map((e) => Result.fromMap(e as Map<String, dynamic>))
            .toList(),
        totalPages: data['total_pages'] as int?,
        currentPage: data['current_page'] as int?,
        hasPrevious: data['has_previous'] as bool?,
        hasNext: data['has_next'] as bool?,
      );

  Map<String, dynamic> toMap() => {
        'results': results?.map((e) => e.toMap()).toList(),
        'total_pages': totalPages,
        'current_page': currentPage,
        'has_previous': hasPrevious,
        'has_next': hasNext,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Product].
  factory Product.fromJson(String data) {
    return Product.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Product] to a JSON string.
  String toJson() => json.encode(toMap());
}
