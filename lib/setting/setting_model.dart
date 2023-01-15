import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:posture_correction/utils.dart';

import '../camera/camera_model.dart';
import '../data.dart';
import '../home/home_model.dart';

class SettingModel extends ChangeNotifier {
  final googleLogin = GoogleSignIn(scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ]);

  int secondsListIndex = 0;

  final secondsList = [
    5,
    10,
    15,
    30,
    45,
    60,
    120,
    180,
    240,
    300,
    600,
    1200,
    1800,
    2400,
    3000,
    3600,
  ];

  googleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userInfo = await FirebaseAuth.instance.currentUser!
          .linkWithCredential(credential);
      print(userInfo.user!.uid);
      print(userInfo.user!.email);
    } catch (e) {
      throw e.toString();
      print(e);
      // print(
      //     "エラー flutter: [firebase_auth/credential-already-in-use] This credential is already associated with a different user account.");
    }
    notifyListeners();
  }

  searchListIndex() {
    secondsList.asMap().forEach((int i, int seconds) {
      if (seconds == Utils.timeToNotification) {
        secondsListIndex = i;
        print('Index: $i' + ' 秒数: $seconds');
        print(Utils.timeToNotification);
      }
    });
  }

  upDateTimeToNotification() async {
    await FirebaseFirestore.instance.collection("users").doc(userId).update({
      "timeToNotification": Utils.timeToNotification,
    });
    print(Utils.timeToNotification);
    notifyListeners();
  }

  logout() async {
    await FirebaseAuth.instance.signOut();
  }

  deleteUser() async {
    try {
      await FirebaseFirestore.instance.collection("users").doc(userId).delete();
      await FirebaseAuth.instance.currentUser!.delete();
      print("done");
    } catch (e) {
      print(e);
    }
  }
}
