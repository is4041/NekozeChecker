import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:posture_correction/signin/signin_page.dart';
import 'package:posture_correction/utils.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

class SignInModel extends ChangeNotifier {
  bool isLoading = false;
  int activePage = 0;

  active() {
    notifyListeners();
  }

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
    final document =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    final userId = document["userId"];
    //初回ログインのみ登録
    //todo 初回ログイン確認まだ
    print("1");
    if (uid != userId) {
      print("2");
      FirebaseFirestore.instance.collection("users").doc(uid).set({
        "userId": uid,
        "createdAt": Timestamp.now(),
        "lastMeasuredOn": "",
        "timeToNotification": 15,
      });
    }
  }

  signInWithAnonymousUser() async {
    throw Error;
    try {
      await firebaseAuth.signInAnonymously();
      final uid = firebaseAuth.currentUser!.uid;
      FirebaseFirestore.instance.collection("users").doc(uid).set({
        "userId": uid,
        "createdAt": Timestamp.now(),
        "lastMeasuredOn": "",
        "timeToNotification": 15,
      });
    } catch (e) {
      throw ("error");
    }
  }
}
