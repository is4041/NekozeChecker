import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:posture_correction/utils.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

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
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "createdAt": Timestamp.now(),
        "greenLineRange": 0.45,
        "timeToNotification": 15,
        "userId": uid,
      });
    }
  }

  //匿名でサインイン
  signInWithAnonymousUser() async {
    await firebaseAuth.signInAnonymously();
    final uid = firebaseAuth.currentUser!.uid;
    FirebaseFirestore.instance.collection("users").doc(uid).set({
      "createdAt": Timestamp.now(),
      "greenLineRange": 0.45,
      "timeToNotification": 15,
      "userId": uid,
    });
  }
}
