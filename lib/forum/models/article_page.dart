// To parse this JSON data, do
//
//     final articlePage = articlePageFromJson(jsonString);

import 'dart:convert';

List<ArticlePage> articlePageFromJson(String str) => List<ArticlePage>.from(json.decode(str).map((x) => ArticlePage.fromJson(x)));

String articlePageToJson(List<ArticlePage> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ArticlePage {
    String model;
    String pk;
    Fields fields;

    ArticlePage({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory ArticlePage.fromJson(Map<String, dynamic> json) => ArticlePage(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    String title;
    String content;
    String? thumbnailFile;  
    String author;
    DateTime createdAt;
    List<Comment> comments;
    bool canEdit;

    Fields({
        required this.title,
        required this.content,
        this.thumbnailFile,
        required this.author,
        required this.createdAt,
        required this.comments,
        required this.canEdit,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        title: json["title"],
        content: json["content"],
        thumbnailFile: json["thumbnail_file"] ?? "/static/image/default-thumbnail.jpg",
        author: json["author"],
        createdAt: DateTime.parse(json["created_at"]),
        comments: List<Comment>.from(json["comments"].map((x) => Comment.fromJson(x))),
        canEdit: json["can_edit"],
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "content": content,
        "thumbnail_file": thumbnailFile,
        "author": author,
        "created_at": createdAt.toIso8601String(),
        "comments": List<dynamic>.from(comments.map((x) => x.toJson())),
        "can_edit": canEdit,
    };
}

class Comment {
    int id;
    String content;
    String author;
    DateTime createdAt;

    Comment({
        required this.id,
        required this.content,
        required this.author,
        required this.createdAt,
    });

    factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json["id"],
        content: json["content"],
        author: json["author"],
        createdAt: _parseDateTime(json["created_at"]),
    );

    static DateTime _parseDateTime(dynamic date) {
        if (date is DateTime) return date;
        
        try {
            if (date is String) {
                // Try parsing ISO format first
                return DateTime.parse(date);
            }
            throw const FormatException('Invalid date format');
        } catch (e) {
            // If parsing fails, return current time as fallback
            return DateTime.now();
        }
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "content": content,
        "author": author,
        "created_at": createdAt.toIso8601String(),
    };
}

// import 'dart:convert';

// List<ArticlePage> articlePageFromJson(String str) => 
//     List<ArticlePage>.from(json.decode(str).map((x) => ArticlePage.fromJson(x)));

// String articlePageToJson(List<ArticlePage> data) => 
//     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class ArticlePage {
//     String model;
//     String pk;
//     Fields fields;

//     ArticlePage({
//         required this.model,
//         required this.pk,
//         required this.fields,
//     });

//     factory ArticlePage.fromJson(Map<String, dynamic> json) => ArticlePage(
//         model: json["model"],
//         pk: json["pk"],
//         fields: Fields.fromJson(json["fields"]),
//     );

//     Map<String, dynamic> toJson() => {
//         "model": model,
//         "pk": pk,
//         "fields": fields.toJson(),
//     };
// }

// class Fields {
//     String title;
//     String content;
//     String thumbnailFile;
//     String? thumbnailImg;
//     String author;
//     DateTime createdAt;
//     List<Comment> comments;
//     bool canEdit;

//     Fields({
//         required this.title,
//         required this.content,
//         required this.thumbnailFile,
//         this.thumbnailImg,
//         required this.author,
//         required this.createdAt,
//         required this.comments,
//         required this.canEdit,
//     });

//     factory Fields.fromJson(Map<String, dynamic> json) => Fields(
//         title: json["title"],
//         content: json["content"],
//         thumbnailFile: json["thumbnail_file"] ?? "/static/image/default-thumbnail.jpg", // Default jika thumbnail kosong
//         author: json["author"],
//         createdAt: DateTime.parse(json["created_at"]),
//         comments: List<Comment>.from(json["comments"].map((x) => Comment.fromJson(x))),
//         canEdit: json["can_edit"],
//     );

//     Map<String, dynamic> toJson() => {
//         "title": title,
//         "content": content,
//         "thumbnail_file": thumbnailFile,
//         "author": author,
//         "created_at": createdAt.toIso8601String(),
//         "comments": List<dynamic>.from(comments.map((x) => x.toJson())),
//         "can_edit": canEdit,
//     };
// }

// class Comment {
//     int id;
//     String content;
//     String author;
//     DateTime createdAt;

//     Comment({
//         required this.id,
//         required this.content,
//         required this.author,
//         required this.createdAt,
//     });

//     factory Comment.fromJson(Map<String, dynamic> json) => Comment(
//         id: json["id"],
//         content: json["content"],
//         author: json["author"],
//         createdAt: DateTime.parse(json["created_at"]),
//     );

//     Map<String, dynamic> toJson() => {
//         "id": id,
//         "content": content,
//         "author": author,
//         "created_at": createdAt.toIso8601String(),
//     };
// }
