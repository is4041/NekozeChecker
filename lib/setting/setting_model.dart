import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:posture_correction/utils.dart';

class SettingModel extends ChangeNotifier {
  final googleLogin = GoogleSignIn(scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ]);

  int secondsListIndex = 0;

  //警告音が鳴るまでの秒数リスト
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

  //匿名アカウントからgoogleアカウントへの更新
  googleSignIn() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    // Create a new credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userInfo =
        await FirebaseAuth.instance.currentUser!.linkWithCredential(credential);
    print(userInfo.user!.uid);
    print(userInfo.user!.email);
    notifyListeners();
  }

  //設定している警告音が鳴るまでの秒数のインデックス番号を取得
  searchListIndex() {
    secondsList.asMap().forEach((int i, int seconds) {
      if (seconds == Utils.timeToNotification) {
        secondsListIndex = i;
        print('Index: $i' + ' 秒数: $seconds秒');
      }
    });
    notifyListeners();
  }

  //姿勢不良になってから警告音が鳴るまでの時間を更新
  upDateTimeToNotification() async {
    await searchListIndex();
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none || Utils.userId.isEmpty) {
      return;
    }
    await FirebaseFirestore.instance
        .collection("users")
        .doc(Utils.userId)
        .update({
      "timeToNotification": Utils.timeToNotification,
    });
    notifyListeners();
  }

  //ログアウト（googleアカウントのみ）
  logout() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw ("通信状態をご確認ください");
    }
    await FirebaseAuth.instance.signOut();
    Utils.percentOfAllGoodPostureSec = 0;
    Utils.percentOfTodayGoodPostureSec = 0;
    Utils.percentOfThisMonthGoodPostureSec = 0;
    Utils.numberOfMeasurementsToday = 0;
    Utils.numberOfMeasurementsThisMonth = 0;
    Utils.numberOfOverallMeasurements = 0;
    Utils.overallMeasuringTime = 0;
    Utils.thisMonthMeasuringTime = 0;
    Utils.todayMeasuringTime = 0;
    Utils.isAnonymous = "";
    Utils.userId = "";
    Utils.timeToNotification = 15;
  }

  //全データ削除（初期化）
  deleteUser() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw ("通信状態をご確認ください");
    } else if (Utils.userId.isEmpty) {
      throw ("ユーザー情報が取得できていません。一度ホームに戻ってから再度試してください");
    }
    await FirebaseFirestore.instance
        .collection('users')
        .doc(Utils.userId)
        .collection("measurements")
        .doc()
        .delete();
    await FirebaseFirestore.instance
        .collection("users")
        .doc(Utils.userId)
        .delete();
    await FirebaseAuth.instance.currentUser!.delete();
    await FirebaseAuth.instance.signOut();
    Utils.percentOfAllGoodPostureSec = 0;
    Utils.percentOfTodayGoodPostureSec = 0;
    Utils.percentOfThisMonthGoodPostureSec = 0;
    Utils.numberOfMeasurementsToday = 0;
    Utils.numberOfMeasurementsThisMonth = 0;
    Utils.numberOfOverallMeasurements = 0;
    Utils.overallMeasuringTime = 0;
    Utils.thisMonthMeasuringTime = 0;
    Utils.todayMeasuringTime = 0;
    Utils.isAnonymous = "";
    Utils.userId = "";
    Utils.timeToNotification = 15;
  }
}
