import 'dart:convert';

Restaurant restaurantFromJson(String str) => Restaurant.fromJson(json.decode(str));

String restaurantToJson(Restaurant data) => json.encode(data.toJson());

class Restaurant {
    List<RestaurantElement> restaurants;
    List<String> kecamatans;
    dynamic selectedKecamatan;
    String searchQuery;
    int totalPages;
    int currentPage;
    bool hasPrevious;
    bool hasNext;

    Restaurant({
        required this.restaurants,
        required this.kecamatans,
        required this.selectedKecamatan,
        required this.searchQuery,
        required this.totalPages,
        required this.currentPage,
        required this.hasPrevious,
        required this.hasNext,
    });

    factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        restaurants: List<RestaurantElement>.from(json["restaurants"].map((x) => RestaurantElement.fromJson(x))),
        kecamatans: List<String>.from(json["kecamatans"].map((x) => x)),
        selectedKecamatan: json["selected_kecamatan"],
        searchQuery: json["search_query"],
        totalPages: json["total_pages"],
        currentPage: json["current_page"],
        hasPrevious: json["has_previous"],
        hasNext: json["has_next"],
    );

    Map<String, dynamic> toJson() => {
        "restaurants": List<dynamic>.from(restaurants.map((x) => x.toJson())),
        "kecamatans": List<dynamic>.from(kecamatans.map((x) => x)),
        "selected_kecamatan": selectedKecamatan,
        "search_query": searchQuery,
        "total_pages": totalPages,
        "current_page": currentPage,
        "has_previous": hasPrevious,
        "has_next": hasNext,
    };
}

class RestaurantElement {
    int id;
    String name;
    String kecamatan;
    String location;
    int menuCount;
    String minPrice;
    String maxPrice;
    String avgPrice;
    String image;
    List<Menu> menus;

    RestaurantElement({
        required this.id,
        required this.name,
        required this.kecamatan,
        required this.location,
        required this.menuCount,
        required this.minPrice,
        required this.maxPrice,
        required this.avgPrice,
        required this.image,
        required this.menus,
    });

    factory RestaurantElement.fromJson(Map<String, dynamic> json) => RestaurantElement(
        id: json["id"],
        name: json["name"],
        kecamatan: json["kecamatan"],
        location: json["location"],
        menuCount: json["menu_count"],
        minPrice: json["min_price"] == null ? '' : json["min_price"].toString(),
        maxPrice: json["max_price"] == null ? '' : json["max_price"].toString(),
        avgPrice: double.parse(json["avg_price"].toString()).toStringAsFixed(2),
        image: json["image"],
        menus: List<Menu>.from(json["menus"].map((x) => Menu.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "kecamatan": kecamatan,
        "location": location,
        "menu_count": menuCount,
        "min_price": minPrice,
        "max_price": maxPrice,
        "avg_price": avgPrice,
        "image": image,
        "menus": List<dynamic>.from(menus.map((x) => x.toJson())),
    };
}

class Menu {
    int id;
    String name;
    String price;
    String image;
    String category;
    String description;

    Menu({
        required this.id,
        required this.name,
        required this.price,
        required this.image,
        required this.category,
        required this.description,
    });

    factory Menu.fromJson(Map<String, dynamic> json) => Menu(
        id: json["id"],
        name: json["name"],
        price: json["price"] == null ? '' : json["price"].toString(),
        image: json["image"],
        category: json["category"],
        description: json["description"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price,
        "image": image,
        "category": category,
        "description": description,
    };
}