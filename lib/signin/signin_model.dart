import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:posture_correction/signin/signin_page.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

class SignInModel extends ChangeNotifier {
  bool isLoading = false;

  startLoading() {
    isLoading = true;
    notifyListeners();
  }

  endLoading() {
    isLoading = false;
    notifyListeners();
  }

  signInWithGoogle() async {
    final user = await googleSignIn.signIn();

    final auth = await user!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    final uid = userCredential.user!.uid;
    FirebaseFirestore.instance.collection("users").doc(uid).set(
        {"userId": uid, "totalAverage": "0", "createdAt": Timestamp.now()});
  }

  signInWithAnonymousUser() async {
    try {
      await firebaseAuth.signInAnonymously();
      final uid = firebaseAuth.currentUser!.uid;
      FirebaseFirestore.instance.collection("users").doc(uid).set(
          {"userId": uid, "totalAverage": "0", "createdAt": Timestamp.now()});
    } catch (e) {
      throw ("error");
    }
  }
}
