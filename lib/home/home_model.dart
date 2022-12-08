import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';

import '../camera/camera_model.dart';
import '../data.dart';
import '../utils.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

class HomeModel extends ChangeNotifier {
  final getDate = Timestamp.now().toDate();
  int averageOfTodayLength = 0;
  int averageOfThisMonthLength = 0;
  int averageOfAllLength = 0;

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
        .where("userId", isEqualTo: userId.toString())
        .get();
    for (var doc in snapshot.docs) {
      //今日の計測時間(分)をリストに追加
      if (doc.get("createdAt").toString().substring(0, 10) ==
          getDate.toString().substring(0, 10)) {
        averageOfToday.add(double.parse(doc.get("measuringMin")));
        averageOfTodayBadPosture
            .add(double.parse(doc.get("measuringBadPostureMin")));
      }

      //今月の計測時間(分)をリストに追加
      if (doc.get("createdAt").toString().substring(0, 7) ==
          getDate.toString().substring(0, 7)) {
        averageOfThisMonth.add(double.parse(doc.get("measuringMin")));
        averageOfThisMonthBadPosture
            .add(double.parse(doc.get("measuringBadPostureMin")));
      }

      //全体の計測時間(分)をリストに追加
      averageOfAll.add(double.parse(doc.get("measuringMin")));
      averageOfAllBadPosture
          .add(double.parse(doc.get("measuringBadPostureMin")));
    }

    //今日の平均を割り出す計算
    if (averageOfToday.isNotEmpty) {
      // print(averageOfToday);
      final totalOfTodayMin = averageOfToday.reduce((a, b) => a + b);
      // print(totalOfTodayMin);
      final totalOfTodayBadPostureMin =
          averageOfTodayBadPosture.reduce((a, b) => a + b);
      // print(totalOfTodayBadPostureMin);
      final totalOfTodayGoodPostureMin =
          totalOfTodayMin - totalOfTodayBadPostureMin;
      // print(totalOfTodayGoodPostureMin);
      final averageOfTodayGoodPostureMin =
          ((totalOfTodayGoodPostureMin / totalOfTodayMin) * 100)
              .toStringAsFixed(1);
      // print(averageOfTodayGoodPostureMin);
      Utils.percentOfTodayGoodPostureMin = averageOfTodayGoodPostureMin;
      Utils.averageOfTodayLength = averageOfToday.length;
    } else {
      Utils.percentOfTodayGoodPostureMin = "0";
      Utils.averageOfTodayLength = 0;
    }

    //今月の平均を割り出す計算
    if (averageOfThisMonth.isNotEmpty) {
      // print(averageOfThisMonth);
      final totalOfThisMonthMin = averageOfThisMonth.reduce((a, b) => a + b);
      // print(totalOfThisMonthMin);
      final totalOfThisMonthBadPostureMin =
          averageOfThisMonthBadPosture.reduce((a, b) => a + b);
      // print(totalOfThisMonthBadPostureMin);
      final totalOfThisMonthGoodPostureMin =
          totalOfThisMonthMin - totalOfThisMonthBadPostureMin;
      // print(totalOfThisMonthGoodPostureMin);
      final averageOfThisMonthGoodPostureMin =
          ((totalOfThisMonthGoodPostureMin / totalOfThisMonthMin) * 100)
              .toStringAsFixed(1);
      // print(averageOfThisMonthGoodPostureMin);
      Utils.percentOfThisMonthGoodPostureMin = averageOfThisMonthGoodPostureMin;
      Utils.averageOfThisMonthLength = averageOfThisMonth.length;
    } else {
      Utils.percentOfThisMonthGoodPostureMin = "0";
      Utils.averageOfThisMonthLength = 0;
    }

    //全体平均を割り出す計算
    if (averageOfAll.isNotEmpty) {
      // print(averageOfAll);
      final totalOfAllMin = averageOfAll.reduce((a, b) => a + b);
      // print(totalOfAllMin);
      final totalOfAllBadPostureMin =
          averageOfAllBadPosture.reduce((a, b) => a + b);
      // print(totalOfAllBadPostureMin);
      final totalOfAllGoodPostureMin = totalOfAllMin - totalOfAllBadPostureMin;
      // print(totalOfAllGoodPostureMin);
      final averageOfAllGoodPostureMin =
          ((totalOfAllGoodPostureMin / totalOfAllMin) * 100).toStringAsFixed(1);
      // print(averageOfAllGoodPostureMin);
      Utils.percentOfAllGoodPostureMin = averageOfAllGoodPostureMin;
      Utils.averageOfAllLength = averageOfAll.length;
    } else {
      Utils.percentOfAllGoodPostureMin = "0";
      Utils.averageOfAllLength = 0;
    }

    // final today = Timestamp.now().toDate().toString().substring(0, 10);
    //
    // DocumentSnapshot snapshot = await firestore.doc("users/$userId").get();
    // final data = snapshot.data() as Map<String, dynamic>;
    //
    // if (today == data["lastMeasuredOn"]) {
    //   Utils.dailyAverage = data["dailyAverage"];
    // } else {
    //   await upDateDailyAverage();
    //   Utils.dailyAverage = "";
    // }
    //
    // if (Utils.totalAverage == null) {
    //   DocumentSnapshot snapshot = await firestore.doc("users/$userId").get();
    //   final data = snapshot.data() as Map<String, dynamic>;
    //
    //   Utils.totalAverage = data["totalAverage"];
    // }
    notifyListeners();
  }

  upDateDailyAverage() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .update({"dailyAverage": ""});
  }
}
