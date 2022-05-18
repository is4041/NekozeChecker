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
      final String seconds = data["seconds"];
      final String numberOfNotifications = data["numberOfNotifications"];
      final String average = data["averageTime"];
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
        if (doc.get("createdAt") == today) {
          dailyTotalSecondsArray.add(double.parse(doc.get("seconds")));
          dailyTotalNotificationsArray
              .add(double.parse(doc.get("numberOfNotifications")));
        }

        totalSecondsArray.add(double.parse(doc.get("seconds")));
        totalNotificationsArray
            .add(double.parse(doc.get("numberOfNotifications")));
      }
    }

    if (dailyTotalSecondsArray.isNotEmpty &&
        dailyTotalNotificationsArray.isNotEmpty) {
      print("dailySec:$dailyTotalSecondsArray");
      print("dailyNot:$dailyTotalNotificationsArray");
      final totalOfSeconds = dailyTotalSecondsArray.reduce((a, b) => a + b);

      final totalOfNotifications =
          dailyTotalNotificationsArray.reduce((a, b) => a + b);
      if (totalOfNotifications > 0) {
        dailyAverage = totalOfSeconds / totalOfNotifications;
        print("今日の平均:${dailyAverage.round()}秒(四捨五入済)");
      } else {
        dailyAverage = "＊";
      }
    } else {
      dailyAverage = "＊";
    }

    if (totalSecondsArray.isNotEmpty && totalNotificationsArray.isNotEmpty) {
      print("totalSec$totalSecondsArray");
      print("totalNot$totalNotificationsArray");
      final totalOfSeconds = totalSecondsArray.reduce((a, b) => a + b);

      final totalOfNotifications =
          totalNotificationsArray.reduce((a, b) => a + b);
      if (totalOfNotifications > 0) {
        totalAverage = totalOfSeconds / totalOfNotifications;
        print("全体の平均:${totalAverage.round()}秒(四捨五入済)");
      } else {
        totalAverage = "＊";
      }
    } else {
      totalAverage = "＊";
    }
  }

  upDateTotalAverage() async {
    await FirebaseFirestore.instance.collection("users").doc(userId).update({
      "dailyAverage": dailyAverage.toString() != "＊"
          ? dailyAverage.round().toString()
          : "＊",
      "totalAverage":
          totalAverage.toString() != "＊" ? totalAverage.round().toString() : "＊"
    });

    if (dailyAverage.toString() != "＊") {
      Utils.dailyAverage = dailyAverage.round().toString();
    } else {
      Utils.dailyAverage = dailyAverage;
    }

    if (totalAverage.toString() != "＊") {
      Utils.totalAverage = totalAverage.round().toString();
    } else {
      Utils.totalAverage = totalAverage;
    }
    print("fromHistoryModel:${Utils.dailyAverage}s");
    print("fromHistoryModel:${Utils.totalAverage}s");
  }

  Future delete(Data data) async {
    print(data.id);
    return FirebaseFirestore.instance
        .collection("measurements")
        .doc(data.id)
        .delete();
  }
}
