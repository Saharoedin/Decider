import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthProvider extends GetConnect {
  User? get currenctUser => FirebaseAuth.instance.currentUser;

  Future<User?> getOrCreateUser() async {
    if (currenctUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
      // initializeAccount();
    }
    return currenctUser;
  }

  initializeAccount() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('users').doc(currenctUser?.uid);

    documentReference.get().then(
      (documentSnapshot) {
        if (!documentSnapshot.exists) {
          documentReference.set({"bank": 3});
        }
      },
    );
  }
}
