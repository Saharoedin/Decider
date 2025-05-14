import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  String? query;
  String? answer;
  DateTime? createdAt;

  Question({
    this.query,
    this.answer,
    this.createdAt,
  });

  Question.fromJson(Map<String, dynamic> json) {
    query = json['query'];
    answer = json['answer'];
    createdAt = (json['created_at'] as Timestamp?)?.toDate();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['query'] = query;
    data['answer'] = answer;
    data['created_at'] = createdAt;
    return data;
  }
}
