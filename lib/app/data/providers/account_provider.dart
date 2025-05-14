import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decider/app/data/models/account_model.dart';
import 'package:get/get.dart';

class AccountProvider extends GetConnect {
  Stream<DocumentSnapshot> getAccountInformation(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  Future<void> updateAccountInformation(
    Account account,
    String uid,
  ) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set(
          account.toJson(),
        );
  }
}
