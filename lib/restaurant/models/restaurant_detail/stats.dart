class Stats {
  int? menuCount;
  String? minPrice;
  String? maxPrice;
  double? avgPrice;

  Stats({this.menuCount, this.minPrice, this.maxPrice, this.avgPrice});

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
        menuCount: json['menu_count'] as int?,
        minPrice: json['min_price'] as String?,
        maxPrice: json['max_price'] as String?,
        avgPrice: json['avg_price'] as double?,
      );

  Map<String, dynamic> toJson() => {
        'menu_count': menuCount,
        'min_price': minPrice,
        'max_price': maxPrice,
        'avg_price': avgPrice,
      };
}
