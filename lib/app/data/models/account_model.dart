import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  String? uid;
  int bank = 0;
  DateTime? nextFreeQuestion;

  Account({
    this.uid,
    required this.bank,
    this.nextFreeQuestion,
  });

  Account.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    bank = json['bank'];
    nextFreeQuestion = (json['next_free_question'] as Timestamp?)?.toDate();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['bank'] = bank;
    data['next_free_question'] = nextFreeQuestion;
    return data;
  }
}
