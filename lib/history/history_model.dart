import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../camera/camera_model.dart';
import '../data.dart';

class HistoryModel extends ChangeNotifier {
  List<Data>? data = [];
  String userId = firebaseAuth.currentUser!.uid;
  dynamic totalAverage;

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
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("measurements").get();
    for (var doc in snapshot.docs) {
      if (doc.get("userId") == userId.toString()) {
        totalSecondsArray.add(double.parse(doc.get("seconds")));
        totalNotificationsArray
            .add(double.parse(doc.get("numberOfNotifications")));
      }
    }

    if (totalSecondsArray.isNotEmpty && totalNotificationsArray.isNotEmpty) {
      print("秒数：${totalSecondsArray}");
      final totalOfSeconds = totalSecondsArray.reduce((a, b) => a + b);
      print("合計秒数:${totalOfSeconds}秒");
      print("通知数：${totalNotificationsArray}");

      final totalOfNotifications =
          totalNotificationsArray.reduce((a, b) => a + b);
      print("合計通知回数:${totalOfNotifications}回");
      if (totalOfNotifications > 0) {
        totalAverage = totalOfSeconds / totalOfNotifications;
        print("平均秒数:${totalAverage}秒(四捨五入)");
      } else {
        totalAverage = "＊";
      }
    } else {
      totalAverage = "＊";
    }
  }

  upDateTotalAverage() async {
    await FirebaseFirestore.instance.collection("users").doc(userId).update({
      "totalAverage":
          totalAverage.toString() != "＊" ? totalAverage.round().toString() : "＊"
    });
  }

  Future delete(Data data) async {
    print(data.id);
    return FirebaseFirestore.instance
        .collection("measurements")
        .doc(data.id)
        .delete();
  }
}
