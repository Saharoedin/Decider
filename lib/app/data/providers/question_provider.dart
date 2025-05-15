import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decider/app/data/providers/auth_provider.dart';
import 'package:get/get.dart';

import '../models/question_model.dart';

class QuestionProvider extends GetConnect {
  Future<Stream> getUserQuestionsList(String uid) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('questions')
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  Future saveToDatabase(Question data) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc('${AuthProvider().currenctUser!.uid}')
        .collection('questions')
        .add(data.toJson());
  }
}
