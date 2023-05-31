import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:posture_correction/signin/signin_page.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

class SignInModel extends ChangeNotifier {
  bool isLoading = false;
  int activePage = 0;

  //ページ更新
  active() {
    notifyListeners();
  }

  //インジケータ表示
  startLoading() {
    isLoading = true;
    notifyListeners();
  }

  //インジケータ非表示
  endLoading() {
    isLoading = false;
    notifyListeners();
  }

  //Googleでサインイン
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
    final exists = document.exists;
    //初回ログイン時だけ作動
    if (exists == false) {
      print("初回ログイン");
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "createdAt": Timestamp.now(),
        "lastMeasuredOn": "",
        "timeToNotification": 15,
        "userId": uid,
      });
    } else {
      print("ログイン履歴あり");
    }
  }

  //匿名でサインイン
  signInWithAnonymousUser() async {
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
