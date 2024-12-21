// Adjusted WishlistCollection model to handle null/missing data safely

import 'dart:convert';

List<WishlistCollection> wishlistCollectionFromJson(String str) =>
    List<WishlistCollection>.from(
        json.decode(str).map((x) => WishlistCollection.fromJson(x)));

String wishlistCollectionToJson(List<WishlistCollection> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class WishlistCollection {
  int id;
  String name;
  String description;
  bool isDefault;
  List<Item> items;

  WishlistCollection({
    required this.id,
    required this.name,
    required this.description,
    required this.isDefault,
    required this.items,
  });

  factory WishlistCollection.fromJson(Map<String, dynamic> json) =>
      WishlistCollection(
        id: json["id"],
        name: json["name"],
        description: json["description"] ?? '', // Default to empty string
        isDefault: json["is_default"],
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "is_default": isDefault,
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
      };
}

class Item {
  int id;
  MenuItem menuItem;
  DateTime createdAt;

  Item({
    required this.id,
    required this.menuItem,
    required this.createdAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"],
        menuItem: MenuItem.fromJson(json["menu_item"]),
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "menu_item": menuItem.toJson(),
        "created_at": createdAt.toIso8601String(),
      };
}

class MenuItem {
  int id;
  String name;
  String price;
  String? image; // Nullable image field to handle missing data

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    this.image,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json["id"],
        name: json["name"],
        price: json["price"],
        image: json["image"] ?? '', // Default to an empty string if missing
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price,
        "image": image,
      };
}
