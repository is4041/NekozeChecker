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
      await getUserData();
      await getAverageData();
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
  getUserId() {
    if (FirebaseAuth.instance.currentUser!.isAnonymous == false) {
      Utils.isAnonymous = false;
    } else {
      Utils.isAnonymous = true;
    }
    Utils.userId = FirebaseAuth.instance.currentUser!.uid;
    print("userId : ${Utils.userId}");
  }

  //ユーザーデータを取得する
  getUserData() async {
    final document = await FirebaseFirestore.instance
        .collection("users")
        .doc(Utils.userId)
        .get();

    Utils.greenLineRange = document["greenLineRange"];
    Utils.timeToNotification = document["timeToNotification"];

    Utils.showTutorial = false;
  }

  //平均データを計算する
  getAverageData() async {
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
          getDate.toString().substring(0, 10)) {
        dataListOfToday.add(doc.get("measuringSec"));
        dataListOfTodayBadPosture.add(doc.get("measuringBadPostureSec"));
      }

      //今月の計測時間(秒)を取得してリストに追加
      if (doc.get("createdAt").toString().substring(0, 7) ==
          getDate.toString().substring(0, 7)) {
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
  calculate({
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
}
