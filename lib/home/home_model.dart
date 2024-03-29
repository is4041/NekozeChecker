import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:posture_correction/camera/camera_page.dart';

import '../utils.dart';

bool gotData = false;

class HomeModel extends ChangeNotifier {
  final _getDate = Timestamp.now().toDate();

  Future<void> getData(BuildContext context) async {
    //オンラインとオフラインで処理を分ける
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      await showConnectError(context);
    } else {
      try {
        if (gotData == false) {
          await addUserData();
          await getUserData();
        }
        await getAverageData();
      } catch (e) {
        await showError(context);
      }
    }
  }

  //オフライン時に表示
  Future<void> showConnectError(context) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("エラー"),
            content: Text("通信状態をご確認ください\n通信状態に問題がない場合は再読み込みをしてください"),
            actions: [
              TextButton(
                child: const Text("再読み込み"),
                onPressed: () {
                  getData(context);
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  //ログイン出来ていない時に表示
  Future<void> showError(context) async {
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("エラー"),
            content: Text("エラーが発生しました。一度アプリを再起動してください。"),
          );
        });
  }

  //firebaseにユーザー情報を追加する
  Future<void> addUserData() async {
    final uid = await FirebaseAuth.instance.currentUser?.uid.toString();
    if (uid == null) {
      throw ("エラーが発生しました。一度アプリを再起動してください。");
    }
    final document =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    final exists = document.exists;
    //初回ログイン時だけ作動
    if (exists == false) {
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "createdAt": Timestamp.now(),
        "greenLineRange": 15.0,
        "nekoMode": false,
        "timeToNotification": 15,
        "userId": uid,
      });
    }
  }

  //ユーザーデータを取得する
  Future<void> getUserData() async {
    final user = await FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw ("エラーが発生しました。一度アプリを再起動してください。");
    }
    Utils.userId = user.uid;
    print("userId : ${Utils.userId}");

    final document = await FirebaseFirestore.instance
        .collection("users")
        .doc(Utils.userId)
        .get();

    Utils.greenLineRange = document["greenLineRange"];
    Utils.nekoMode = document["nekoMode"];
    Utils.timeToNotification = document["timeToNotification"];
    Utils.showTutorial = false;
    gotData = true;
  }

  //データを『今日・今月・全体』にわけて配列にいれる
  Future<void> getAverageData() async {
    if (FirebaseAuth.instance.currentUser == null) {
      throw ("エラーが発生しました。一度アプリを再起動してください。");
    }
    //今日のデータリスト
    List dataListOfToday = [];
    List dataListOfTodayBadPosture = [];

    //今月のデータリスト
    List dataListOfThisMonth = [];
    List dataListOfThisMonthBadPosture = [];

    //全体のデータリスト
    List dataListOfAll = [];
    List dataListOfAllBadPosture = [];

    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(Utils.userId)
        .collection("measurements")
        .get();

    for (var doc in snapshot.docs) {
      //今日の計測時間(秒)を取得してリストに追加
      if (doc.get("createdAt").toString().substring(0, 10) ==
          _getDate.toString().substring(0, 10)) {
        dataListOfToday.add(doc.get("measuringSec"));
        dataListOfTodayBadPosture.add(doc.get("measuringBadPostureSec"));
      }

      //今月の計測時間(秒)を取得してリストに追加
      if (doc.get("createdAt").toString().substring(0, 7) ==
          _getDate.toString().substring(0, 7)) {
        dataListOfThisMonth.add(doc.get("measuringSec"));
        dataListOfThisMonthBadPosture.add(doc.get("measuringBadPostureSec"));
      }

      //全ての計測時間(秒)を取得してリストに追加
      dataListOfAll.add(doc.get("measuringSec"));
      dataListOfAllBadPosture.add(doc.get("measuringBadPostureSec"));
    }

    //今日の計測データを集計する
    calculate(
      dateRange: '今日',
      dataList: dataListOfToday,
      dataListOfBadPosture: dataListOfTodayBadPosture,
    );

    //今月の計測データを集計する
    calculate(
      dateRange: '今月',
      dataList: dataListOfThisMonth,
      dataListOfBadPosture: dataListOfThisMonthBadPosture,
    );

    //全ての計測データを集計する
    calculate(
      dateRange: '全体',
      dataList: dataListOfAll,
      dataListOfBadPosture: dataListOfAllBadPosture,
    );
    notifyListeners();
  }

  //計測データを集計する
  void calculate({
    required String dateRange,
    required List dataList,
    required List dataListOfBadPosture,
  }) {
    int totalMeasurementTime = 0;
    double percentOfGoodPostureSec = 0;
    int numberOfMeasurements = 0;

    if (dataList.isNotEmpty) {
      totalMeasurementTime = dataList.reduce((a, b) => a + b);
      final totalOfBadPostureSec = dataListOfBadPosture.reduce((a, b) => a + b);
      final totalOfGoodPostureSec = totalMeasurementTime - totalOfBadPostureSec;

      percentOfGoodPostureSec = double.parse(
          ((totalOfGoodPostureSec / totalMeasurementTime) * 100)
              .toStringAsFixed(1));

      numberOfMeasurements = dataList.length;
    }

    if (dateRange == "今日") {
      Utils.totalMeasurementTimeForTheDay = totalMeasurementTime;
      Utils.percentOfTodayGoodPostureSec = percentOfGoodPostureSec;
      Utils.numberOfMeasurementsToday = numberOfMeasurements;
    } else if (dateRange == "今月") {
      Utils.totalMeasurementTimeForThisMonth = totalMeasurementTime;
      Utils.percentOfThisMonthGoodPostureSec = percentOfGoodPostureSec;
      Utils.numberOfMeasurementsThisMonth = numberOfMeasurements;
    } else if (dateRange == "全体") {
      Utils.totalMeasurementTimeForAll = totalMeasurementTime;
      Utils.percentOfAllGoodPostureSec = percentOfGoodPostureSec;
      Utils.numberOfAllMeasurements = numberOfMeasurements;
    }
  }

  //画面遷移後に通知音がなるのを防ぐ
  void audioStop() {
    Future.delayed(Duration(seconds: 1), () {
      notificationTimer?.cancel();
      audioPlayer.stop();
    });
  }
}
