
// menu_item.dart
class MenuItem {
  final String? item;
  final String? image;
  final String? description;
  final String? categories;
  final int? price;

  MenuItem({
    this.item,
    this.image,
    this.description,
    this.categories,
    this.price,
  });

  factory MenuItem.fromMap(Map<String, dynamic> data) => MenuItem(
        item: data['item'] as String?,
        image: data['image'] as String?,
        description: data['description'] as String?,
        categories: data['categories'] as String?,
        price: data['price'] as int?,
      );

  Map<String, dynamic> toMap() => {
        'item': item,
        'image': image,
        'description': description,
        'categories': categories,
        'price': price,
      };
}