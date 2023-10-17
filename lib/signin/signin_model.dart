import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../camera/camera_page.dart';

class SignInModel extends ChangeNotifier {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  bool isLoading = false;
  int activePage = 0;

  //ページ更新
  void active() {
    notifyListeners();
  }

  //インジケータ表示
  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  //インジケータ非表示
  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

//画面遷移後に通知音がなるのを防ぐ
  void audioStop() {
    Future.delayed(Duration(seconds: 1), () {
      notificationTimer?.cancel();
      audioPlayer.stop();
    });
  }

  //Googleでサインイン
  Future<UserCredential> signInWithGoogle() async {
    final user = await googleSignIn.signIn();
    final auth = await user!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    if (FirebaseAuth.instance.currentUser == null) {
      throw ("エラーが発生しました。一度アプリを再起動してください。");
    }
    return userCredential;
  }

  //Appleでサインイン
  Future<UserCredential> signInWithApple() async {
    final rawNonce = generateNonce();
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );
    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    if (FirebaseAuth.instance.currentUser == null) {
      throw ("エラーが発生しました。一度アプリを再起動してください。");
    }
    return userCredential;
  }
}
