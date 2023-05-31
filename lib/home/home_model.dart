import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';

import '../camera/camera_model.dart';
import '../utils.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

class HomeModel extends ChangeNotifier {
  final getDate = Timestamp.now().toDate();

  //Tfliteをロードする
  Future loadModel() async {
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
  }

  //警告音が鳴るまでの時間を取得する
  getTimeToNotification() async {
    final document =
        await firestore.collection("users").doc(Utils.userId).get();
    final exists = document.exists;
    if (exists == true) {
      print("ログイン履歴あり");
      Utils.timeToNotification = document["timeToNotification"];
      print("設定秒数 : ${Utils.timeToNotification}秒");
    } else {
      print("初回ログイン");
      print("設定秒数 : ${Utils.timeToNotification}秒");
    }
  }

  //ProviderIdを取得する
  getProviderId() {
    if (FirebaseAuth.instance.currentUser!.isAnonymous == false) {
      print("googleUser");
      Utils.isAnonymous = "isNotAnonymous";
    } else {
      print("anonymousUser");
      Utils.isAnonymous = "isAnonymous";
    }
  }

  //userIdを取得する
  getUserId() async {
    Utils.userId = firebaseAuth.currentUser!.uid;
    print("userId : ${Utils.userId}");
    Utils.showTutorial = false;
    print("showTutorial : ${Utils.showTutorial}");
  }

  //平均データを取得する
  getAverage() async {
    //今日の平均リスト
    List averageOfToday = [];
    List averageOfTodayBadPosture = [];

    //今月の平均リスト
    List averageOfThisMonth = [];
    List averageOfThisMonthBadPosture = [];

    //全体の平均リスト
    List averageOfAll = [];
    List averageOfAllBadPosture = [];

    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('measurements')
        .where("userId", isEqualTo: Utils.userId.toString())
        .get();
    for (var doc in snapshot.docs) {
      //今日の計測時間(分)をリストに追加
      if (doc.get("createdAt").toString().substring(0, 10) ==
          getDate.toString().substring(0, 10)) {
        averageOfToday.add(doc.get("measuringSec"));
        averageOfTodayBadPosture.add(doc.get("measuringBadPostureSec"));
      }

      //今月の計測時間(分)をリストに追加
      if (doc.get("createdAt").toString().substring(0, 7) ==
          getDate.toString().substring(0, 7)) {
        averageOfThisMonth.add(doc.get("measuringSec"));
        averageOfThisMonthBadPosture.add(doc.get("measuringBadPostureSec"));
      }

      //全体の計測時間(分)をリストに追加
      averageOfAll.add(doc.get("measuringSec"));
      averageOfAllBadPosture.add(doc.get("measuringBadPostureSec"));
    }

    //今日の平均を割り出す計算
    if (averageOfToday.isNotEmpty) {
      final totalOfTodaySec = averageOfToday.reduce((a, b) => a + b);
      final totalOfTodayBadPostureSec =
          averageOfTodayBadPosture.reduce((a, b) => a + b);
      final totalOfTodayGoodPostureSec =
          totalOfTodaySec - totalOfTodayBadPostureSec;
      Utils.percentOfTodayGoodPostureSec = double.parse(
          ((totalOfTodayGoodPostureSec / totalOfTodaySec) * 100)
              .toStringAsFixed(1));

      Utils.numberOfMeasurementsToday = averageOfToday.length;
      Utils.todayMeasuringTime = totalOfTodaySec;
    } else {
      Utils.todayMeasuringTime = 0;
      Utils.percentOfTodayGoodPostureSec = 0;
      Utils.numberOfMeasurementsToday = 0;
    }

    //今月の平均を割り出す計算
    if (averageOfThisMonth.isNotEmpty) {
      final totalOfThisMonthSec = averageOfThisMonth.reduce((a, b) => a + b);
      final totalOfThisMonthBadPostureSec =
          averageOfThisMonthBadPosture.reduce((a, b) => a + b);
      final totalOfThisMonthGoodPostureSec =
          totalOfThisMonthSec - totalOfThisMonthBadPostureSec;
      final averageOfThisMonthGoodPostureSec = double.parse(
          ((totalOfThisMonthGoodPostureSec / totalOfThisMonthSec) * 100)
              .toStringAsFixed(1));

      Utils.percentOfThisMonthGoodPostureSec = averageOfThisMonthGoodPostureSec;
      Utils.numberOfMeasurementsThisMonth = averageOfThisMonth.length;
      Utils.thisMonthMeasuringTime = totalOfThisMonthSec;
    } else {
      Utils.thisMonthMeasuringTime = 0;
      Utils.percentOfThisMonthGoodPostureSec = 0;
      Utils.numberOfMeasurementsThisMonth = 0;
    }

    //全体平均を割り出す計算
    if (averageOfAll.isNotEmpty) {
      final totalOfAllSec = averageOfAll.reduce((a, b) => a + b);
      final totalOfAllBadPostureSec =
          averageOfAllBadPosture.reduce((a, b) => a + b);
      final totalOfAllGoodPostureSec = totalOfAllSec - totalOfAllBadPostureSec;
      final averageOfAllGoodPostureSec = double.parse(
          ((totalOfAllGoodPostureSec / totalOfAllSec) * 100)
              .toStringAsFixed(1));

      Utils.percentOfAllGoodPostureSec = averageOfAllGoodPostureSec;
      Utils.numberOfOverallMeasurements = averageOfAll.length;
      Utils.overallMeasuringTime = totalOfAllSec;
    } else {
      Utils.overallMeasuringTime = 0;
      Utils.percentOfAllGoodPostureSec = 0;
      Utils.numberOfOverallMeasurements = 0;
    }

    notifyListeners();
  }
}
