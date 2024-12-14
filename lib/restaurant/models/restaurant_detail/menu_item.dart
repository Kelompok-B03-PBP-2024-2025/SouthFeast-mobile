class MenuItem {
  int? id;
  String? name;
  String? description;
  String? price;
  String? image;
  String? category;

  MenuItem({
    this.id,
    this.name,
    this.description,
    this.price,
    this.image,
    this.category,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json['id'] as int?,
        name: json['name'] as String?,
        description: json['description'] as String?,
        price: json['price'] as String?,
        image: json['image'] as String?,
        category: json['category'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'image': image,
        'category': category,
      };
}
