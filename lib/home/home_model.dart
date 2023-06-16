import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';

import '../utils.dart';

class HomeModel extends ChangeNotifier {
  final getDate = Timestamp.now().toDate();

  //Tfliteをロードする
  Future loadModel(BuildContext context) async {
    Tflite.close();
    try {
      String? res;
      res = await Tflite.loadModel(
        model: "assets/posenet_mv1_075_float_from_checkpoints.tflite",
      );
      print(res);
    } on PlatformException {
      print("Failed to load model");
    }

    //オンラインとオフラインで処理を分ける
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      await showConnectError(context);
    } else {
      await getUserId();
      await getAverage();
      await getTimeToNotification();
      await getProviderId();
    }
  }

  //オフライン時に表示
  showConnectError(context) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("エラー"),
            content: Text("通信状態をご確認ください"),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  //userIdを取得する
  getUserId() async {
    Utils.userId = FirebaseAuth.instance.currentUser!.uid;
    print("userId : ${Utils.userId}");
    Utils.showTutorial = false;
  }

  //平均データを取得する
  getAverage() async {
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
      //今日の計測時間(秒)をリストに追加
      if (doc.get("createdAt").toString().substring(0, 10) ==
          getDate.toString().substring(0, 10)) {
        dataListOfToday.add(doc.get("measuringSec"));
        dataListOfTodayBadPosture.add(doc.get("measuringBadPostureSec"));
      }

      //今月の計測時間(秒)をリストに追加
      if (doc.get("createdAt").toString().substring(0, 7) ==
          getDate.toString().substring(0, 7)) {
        dataListOfThisMonth.add(doc.get("measuringSec"));
        dataListOfThisMonthBadPosture.add(doc.get("measuringBadPostureSec"));
      }

      //全体の計測時間(秒)をリストに追加
      dataListOfAll.add(doc.get("measuringSec"));
      dataListOfAllBadPosture.add(doc.get("measuringBadPostureSec"));
    }

    //今日の平均データを割り出す計算
    if (dataListOfToday.isNotEmpty) {
      final totalOfTodaySec = dataListOfToday.reduce((a, b) => a + b);
      final totalOfTodayBadPostureSec =
          dataListOfTodayBadPosture.reduce((a, b) => a + b);
      final totalOfTodayGoodPostureSec =
          totalOfTodaySec - totalOfTodayBadPostureSec;
      Utils.percentOfTodayGoodPostureSec = double.parse(
          ((totalOfTodayGoodPostureSec / totalOfTodaySec) * 100)
              .toStringAsFixed(1));

      Utils.numberOfMeasurementsToday = dataListOfToday.length;
      Utils.todayMeasuringTime = totalOfTodaySec;
    } else {
      Utils.todayMeasuringTime = 0;
      Utils.percentOfTodayGoodPostureSec = 0;
      Utils.numberOfMeasurementsToday = 0;
    }

    //今月の平均データを割り出す計算
    if (dataListOfThisMonth.isNotEmpty) {
      final totalOfThisMonthSec = dataListOfThisMonth.reduce((a, b) => a + b);
      final totalOfThisMonthBadPostureSec =
          dataListOfThisMonthBadPosture.reduce((a, b) => a + b);
      final totalOfThisMonthGoodPostureSec =
          totalOfThisMonthSec - totalOfThisMonthBadPostureSec;
      final averageOfThisMonthGoodPostureSec = double.parse(
          ((totalOfThisMonthGoodPostureSec / totalOfThisMonthSec) * 100)
              .toStringAsFixed(1));

      Utils.percentOfThisMonthGoodPostureSec = averageOfThisMonthGoodPostureSec;
      Utils.numberOfMeasurementsThisMonth = dataListOfThisMonth.length;
      Utils.thisMonthMeasuringTime = totalOfThisMonthSec;
    } else {
      Utils.thisMonthMeasuringTime = 0;
      Utils.percentOfThisMonthGoodPostureSec = 0;
      Utils.numberOfMeasurementsThisMonth = 0;
    }

    //全体平均のデータを割り出す計算
    if (dataListOfAll.isNotEmpty) {
      final totalOfAllSec = dataListOfAll.reduce((a, b) => a + b);
      final totalOfAllBadPostureSec =
          dataListOfAllBadPosture.reduce((a, b) => a + b);
      final totalOfAllGoodPostureSec = totalOfAllSec - totalOfAllBadPostureSec;
      final averageOfAllGoodPostureSec = double.parse(
          ((totalOfAllGoodPostureSec / totalOfAllSec) * 100)
              .toStringAsFixed(1));

      Utils.percentOfAllGoodPostureSec = averageOfAllGoodPostureSec;
      Utils.numberOfOverallMeasurements = dataListOfAll.length;
      Utils.overallMeasuringTime = totalOfAllSec;
    } else {
      Utils.overallMeasuringTime = 0;
      Utils.percentOfAllGoodPostureSec = 0;
      Utils.numberOfOverallMeasurements = 0;
    }

    notifyListeners();
  }

  //警告音が鳴るまでの時間を取得する
  getTimeToNotification() async {
    final document = await FirebaseFirestore.instance
        .collection("users")
        .doc(Utils.userId)
        .get();
    final exists = document.exists;
    if (exists == true) {
      print("ログイン履歴あり");
      Utils.timeToNotification = document["timeToNotification"];
      print("設定秒数 : ${Utils.timeToNotification}秒");
    } else {
      print("初回ログイン");
    }
  }

  //ProviderIdを取得する
  getProviderId() {
    if (FirebaseAuth.instance.currentUser!.isAnonymous == false) {
      // print("googleUser");
      Utils.isAnonymous = "isNotAnonymous";
    } else {
      // print("anonymousUser");
      Utils.isAnonymous = "isAnonymous";
    }
  }
}
