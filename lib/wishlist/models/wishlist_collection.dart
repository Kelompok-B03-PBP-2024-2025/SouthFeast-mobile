// To parse this JSON data, do
//
//     final wishlistCollection = wishlistCollectionFromJson(jsonString);

import 'dart:convert';

WishlistCollection wishlistCollectionFromJson(String str) => WishlistCollection.fromJson(json.decode(str));

String wishlistCollectionToJson(WishlistCollection data) => json.encode(data.toJson());

class WishlistCollection {
    List<Result> results;
    int totalPages;
    int currentPage;
    bool hasPrevious;
    bool hasNext;
    int totalItems;
    String filterType;
    String searchQuery;

    WishlistCollection({
        required this.results,
        required this.totalPages,
        required this.currentPage,
        required this.hasPrevious,
        required this.hasNext,
        required this.totalItems,
        required this.filterType,
        required this.searchQuery,
    });

    factory WishlistCollection.fromJson(Map<String, dynamic> json) => WishlistCollection(
        results: List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
        totalPages: json["total_pages"],
        currentPage: json["current_page"],
        hasPrevious: json["has_previous"],
        hasNext: json["has_next"],
        totalItems: json["total_items"],
        filterType: json["filter_type"],
        searchQuery: json["search_query"],
    );

    Map<String, dynamic> toJson() => {
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
        "total_pages": totalPages,
        "current_page": currentPage,
        "has_previous": hasPrevious,
        "has_next": hasNext,
        "total_items": totalItems,
        "filter_type": filterType,
        "search_query": searchQuery,
    };
}

class Result {
    int id;
    String name;
    String description;
    bool isDefault;
    List<Item> items;
    int itemsCount;

    Result({
        required this.id,
        required this.name,
        required this.description,
        required this.isDefault,
        required this.items,
        required this.itemsCount,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        isDefault: json["is_default"],
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
        itemsCount: json["items_count"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "is_default": isDefault,
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
        "items_count": itemsCount,
    };
}

class Item {
    int id;
    MenuItem menuItem;
    String createdAt;

    Item({
        required this.id,
        required this.menuItem,
        required this.createdAt,
    });

    factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"],
        menuItem: MenuItem.fromJson(json["menu_item"]),
        createdAt: json["created_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "menu_item": menuItem.toJson(),
        "created_at": createdAt,
    };
}

class MenuItem {
    int id;
    String name;
    String price;

    MenuItem({
        required this.id,
        required this.name,
        required this.price,
    });

    factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json["id"],
        name: json["name"],
        price: json["price"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price,
    };
}
