import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../camera/camera_model.dart';
import '../data.dart';
import '../utils.dart';

class HistoryModel extends ChangeNotifier {
  List<Data>? data = [];
  String userId = firebaseAuth.currentUser!.uid;
  dynamic totalAverage;
  dynamic dailyAverage;

  void fetchData() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('measurements').get();

    final List<Data> data = snapshot.docs.map((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
      final String seconds = data["measuringSec"];
      final String numberOfNotifications = data["numberOfNotifications"];
      final String average = data["averageMin"];
      final String userId = data["userId"];
      final String createdAt = data["createdAt"];
      final String id = document.id;
      return Data(
          seconds, numberOfNotifications, average, userId, createdAt, id);
    }).toList();
    this.data = data;
    notifyListeners();
  }

  Future calculateTotalAverage() async {
    List totalSecondsArray = [];
    List totalNotificationsArray = [];
    List dailyTotalSecondsArray = [];
    List dailyTotalNotificationsArray = [];
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("measurements").get();
    for (var doc in snapshot.docs) {
      if (doc.get("userId") == userId.toString()) {
        //当日の計測（秒数、警告回数）を配列に追加
        if (doc.get("createdAt").toString().substring(0, 10) == today) {
          dailyTotalSecondsArray.add(double.parse(doc.get("measuringSec")));
          dailyTotalNotificationsArray
              .add(double.parse(doc.get("numberOfNotifications")));
        }
        //全データの計測（秒数、警告回数）を配列に追加
        totalSecondsArray.add(double.parse(doc.get("measuringSec")));
        totalNotificationsArray
            .add(double.parse(doc.get("numberOfNotifications")));
      }
    }
    //当日の計測データ（秒数、警告回数）がisNotEmptyでなければそれぞれのデータの合計値を割り出す
    if (dailyTotalSecondsArray.isNotEmpty &&
        dailyTotalNotificationsArray.isNotEmpty) {
      print("本日の計測秒数リスト: $dailyTotalSecondsArray");
      print("本日の警告回数リスト: $dailyTotalNotificationsArray");
      final totalOfDailySeconds =
          dailyTotalSecondsArray.reduce((a, b) => a + b);
      print("本日の計測秒数の総計: $totalOfDailySeconds");

      final totalOfDailyNotifications =
          dailyTotalNotificationsArray.reduce((a, b) => a + b);
      print("本日の警告回数の総計: $totalOfDailyNotifications");
      //当日の計測データの平均値を割り出す（計測時間÷警告回数＝何秒に一度警告されたか）
      if (totalOfDailyNotifications > 0) {
        dailyAverage = totalOfDailySeconds / totalOfDailyNotifications / 60;
        print("本日の平均:${dailyAverage.round()}分(四捨五入)");
        //警告回数が0なら計算不可のため＊を代入
      } else {
        dailyAverage = "";
      }
      //データなしでは計算不可のため＊を代入
    } else {
      dailyAverage = "";
    }
    //上記の全データver
    if (totalSecondsArray.isNotEmpty && totalNotificationsArray.isNotEmpty) {
      print("全ての計測秒数リスト: $totalSecondsArray");
      print("全ての警告回数リスト: $totalNotificationsArray");
      final totalOfSeconds = totalSecondsArray.reduce((a, b) => a + b);
      print("全ての計測秒数の総計: $totalOfSeconds");

      final totalOfNotifications =
          totalNotificationsArray.reduce((a, b) => a + b);
      print("全ての警告回数の総計: $totalOfNotifications");
      if (totalOfNotifications > 0) {
        totalAverage = totalOfSeconds / totalOfNotifications / 60;
        print("全体の平均:${totalAverage.round()}分(四捨五入)");
      } else {
        totalAverage = "";
      }
    } else {
      totalAverage = "";
    }
  }

  upDateTotalAverage() async {
    await FirebaseFirestore.instance.collection("users").doc(userId).update({
      "dailyAverage":
          dailyAverage.toString() != "" ? dailyAverage.round().toString() : "",
      "totalAverage":
          totalAverage.toString() != "" ? totalAverage.round().toString() : ""
    });

    if (dailyAverage.toString() != "") {
      Utils.dailyAverage = dailyAverage.round().toString();
    } else {
      Utils.dailyAverage = dailyAverage;
    }

    if (totalAverage.toString() != "") {
      Utils.totalAverage = totalAverage.round().toString();
    } else {
      Utils.totalAverage = totalAverage;
    }
  }

  Future delete(Data data) async {
    print(data.id);
    return FirebaseFirestore.instance
        .collection("measurements")
        .doc(data.id)
        .delete();
  }
}
