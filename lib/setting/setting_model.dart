import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:posture_correction/home/home_model.dart';
import 'package:posture_correction/signin/signin_page.dart';
import 'package:posture_correction/utils.dart';

class SettingModel extends ChangeNotifier {
  final googleLogin = GoogleSignIn(scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ]);

  int secondsListIndex = 0;

  //警告音が鳴るまでの秒数リスト
  final secondsList = [
    1,
    2,
    3,
    4,
    5,
    10,
    15,
    20,
    25,
    30,
    35,
    40,
    45,
    50,
    55,
    60,
  ];

  //白点がグリーンラインの枠外に出た時に警告するまでの時間を更新
  Future<void> upDateTimeToNotification() async {
    searchListIndex();
    if (tryOutMode == true) return;
    if (FirebaseAuth.instance.currentUser == null) return;
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none || Utils.userId.isEmpty)
      return;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(Utils.userId)
        .update({
      "timeToNotification": Utils.timeToNotification,
    });
    notifyListeners();
  }

  //設定している警告音が鳴るまでの秒数のインデックス番号を取得
  void searchListIndex() {
    secondsList.asMap().forEach((int i, int seconds) {
      if (seconds == Utils.timeToNotification) {
        secondsListIndex = i;
      }
    });
    notifyListeners();
  }

  //グリーンラインの間隔の調整内容を更新する
  Future<void> changeGreenLineRange() async {
    notifyListeners();
    if (tryOutMode == true) return;
    if (FirebaseAuth.instance.currentUser == null) return;
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none || Utils.userId.isEmpty)
      return;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(Utils.userId)
        .update({
      "greenLineRange": Utils.greenLineRange,
    });
    notifyListeners();
  }

  //ネコモードのオンオフ
  Future<void> isOnNekoMode() async {
    notifyListeners();
    if (tryOutMode == true) return;
    if (FirebaseAuth.instance.currentUser == null) return;
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none || Utils.userId.isEmpty)
      return;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(Utils.userId)
        .update({
      "nekoMode": Utils.nekoMode,
    });
    notifyListeners();
  }

  //ログアウト
  Future<void> logout() async {
    if (FirebaseAuth.instance.currentUser == null) {
      throw ("エラーが発生しました。一度アプリを再起動してください。");
    }
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw ("ログアウトに失敗しました。通信状態をご確認ください");
    } else if (Utils.userId.isEmpty) {
      throw ("ユーザー情報が取得できていません。ホーム画面に戻るとユーザー情報が取得されます。");
    }
    await FirebaseAuth.instance.signOut();
    Utils.userId = "";
    Utils.timeToNotification = 15;
    Utils.greenLineRange = 15;
    Utils.percentOfAllGoodPostureSec = 0;
    Utils.percentOfTodayGoodPostureSec = 0;
    Utils.percentOfThisMonthGoodPostureSec = 0;
    Utils.numberOfMeasurementsToday = 0;
    Utils.numberOfMeasurementsThisMonth = 0;
    Utils.numberOfAllMeasurements = 0;
    Utils.totalMeasurementTimeForAll = 0;
    Utils.totalMeasurementTimeForThisMonth = 0;
    Utils.totalMeasurementTimeForTheDay = 0;
    gotData = false;
  }

  //アカウント削除
  Future<void> deleteUser() async {
    if (FirebaseAuth.instance.currentUser == null) {
      throw ("エラーが発生しました。一度アプリを再起動してください。");
    }
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw ("削除に失敗しました。通信状態をご確認ください");
    } else if (Utils.userId.isEmpty) {
      throw ("ユーザー情報が取得できていません。ホーム画面に戻るとユーザー情報が取得されます。");
    }
    try {
      await FirebaseAuth.instance.currentUser!.delete();
    } catch (e) {
      throw ("アカウントが削除出来ませんでした。\n一度ログアウトし、再ログインした後にもう一度試してください。");
    }
    await FirebaseAuth.instance.signOut();
    Utils.userId = "";
    Utils.timeToNotification = 15;
    Utils.greenLineRange = 15;
    Utils.percentOfAllGoodPostureSec = 0;
    Utils.percentOfTodayGoodPostureSec = 0;
    Utils.percentOfThisMonthGoodPostureSec = 0;
    Utils.numberOfMeasurementsToday = 0;
    Utils.numberOfMeasurementsThisMonth = 0;
    Utils.numberOfAllMeasurements = 0;
    Utils.totalMeasurementTimeForAll = 0;
    Utils.totalMeasurementTimeForThisMonth = 0;
    Utils.totalMeasurementTimeForTheDay = 0;
    gotData = false;
  }
}
