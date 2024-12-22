// To parse this JSON data, do
//
//     final qnaPage = qnaPageFromJson(jsonString);

import 'dart:convert';

QnaPage qnaPageFromJson(String str) => QnaPage.fromJson(json.decode(str));

String qnaPageToJson(QnaPage data) => json.encode(data.toJson());

class QnaPage {
    List<Result> results;
    int totalPages;
    int currentPage;
    bool hasPrevious;
    bool hasNext;
    String filterType;

    QnaPage({
        required this.results,
        required this.totalPages,
        required this.currentPage,
        required this.hasPrevious,
        required this.hasNext,
        required this.filterType,
    });

    factory QnaPage.fromJson(Map<String, dynamic> json) => QnaPage(
        results: List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
        totalPages: json["total_pages"],
        currentPage: json["current_page"],
        hasPrevious: json["has_previous"],
        hasNext: json["has_next"],
        filterType: json["filter_type"],
    );

    Map<String, dynamic> toJson() => {
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
        "total_pages": totalPages,
        "current_page": currentPage,
        "has_previous": hasPrevious,
        "has_next": hasNext,
        "filter_type": filterType,
    };
}

class Result {
    String model;
    int pk;
    ResultFields fields;

    Result({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        model: json["model"],
        pk: json["pk"] is String ? int.parse(json["pk"]) : json["pk"] as int,
        fields: ResultFields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class ResultFields {
    String title;
    String question;
    String author;
    String createdAt;
    bool answered;
    int answerCount;
    String url;
    bool canEdit;
    bool isStaff;
    List<Answer> answers;

    ResultFields({
        required this.title,
        required this.question,
        required this.author,
        required this.createdAt,
        required this.answered,
        required this.answerCount,
        required this.url,
        required this.canEdit,
        required this.isStaff,
        required this.answers,
    });

    factory ResultFields.fromJson(Map<String, dynamic> json) => ResultFields(
        title: json["title"],
        question: json["question"],
        author: json["author"],
        createdAt: json["created_at"],
        answered: json["answered"],
        answerCount: json["answer_count"],
        url: json["url"],
        canEdit: json["can_edit"] ?? false,
        isStaff: json['is_staff'] ?? false,
        answers: List<Answer>.from(json["answers"].map((x) => Answer.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "question": question,
        "author": author,
        "created_at": createdAt,
        "answered": answered,
        "answer_count": answerCount,
        "url": url,
        "can_edit": canEdit,
        "is_staff" : isStaff,
        "answers": List<dynamic>.from(answers.map((x) => x.toJson())),
    };
}

class Answer {
    String model;
    String pk;
    AnswerFields fields;

    Answer({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Answer.fromJson(Map<String, dynamic> json) => Answer(
        model: json["model"],
        pk: json["pk"],
        fields: AnswerFields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class AnswerFields {
    String content;
    String author;
    String createdAt;
    bool canEdit;
    bool isStaff;

    AnswerFields({
        required this.content,
        required this.author,
        required this.createdAt,
        required this.canEdit,
        required this.isStaff
    });

    factory AnswerFields.fromJson(Map<String, dynamic> json) => AnswerFields(
        content: json["content"],
        author: json["author"],
        createdAt: json["created_at"],
        canEdit: json["can_edit"] ?? false,
        isStaff: json['is_staff'] ?? false,
    );

    Map<String, dynamic> toJson() => {
        "content": content,
        "author": author,
        "created_at": createdAt,
        "can_edit": canEdit,
        "is_staff": isStaff,
    };
}
