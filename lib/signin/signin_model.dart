import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:posture_correction/signin/signin_page.dart';

// final auth = FirebaseAuth.instance;
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
    if (user == null) {
    } else {
      final auth = await user.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    }
    notifyListeners();
  }

  onSignInWithAnonymousUser() async {
    try {
      await firebaseAuth.signInAnonymously();
    } catch (e) {
      throw ("error");
    }
  }
}
