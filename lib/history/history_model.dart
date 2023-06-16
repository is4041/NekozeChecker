import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:posture_correction/utils.dart';

import '../data.dart';

class HistoryModel extends ChangeNotifier {
  bool isLoading = false;
  bool showSwitch = false;
  List<Map<String, String>> data5 = [];
  List<Data>? data = [];
  String memo = "";
  dynamic totalAverage;
  dynamic dailyAverage;

  //データ取得
  Future fetchData() async {
    isLoading = true;
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(Utils.userId)
        .collection("measurements")
        .orderBy("createdAt", descending: true)
        .get();

    final data = snapshot.docs.map((doc) => Data(doc)).toList();
    this.data = data;

    isLoading = false;
    notifyListeners();
  }

  //メモをアップデート
  Future updateTitle(Data data) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return;
    }
    await FirebaseFirestore.instance
        .collection("users")
        .doc(Utils.userId)
        .collection("measurements")
        .doc(data.documentID)
        .update(memo.isNotEmpty
            ? {"memo": memo}
            : {
                "memo": "",
              });

    await fetchData();
  }

  //計測データ消去
  Future delete(Data data) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw ("通信状態をご確認ください");
    }
    await FirebaseFirestore.instance
        .collection("users")
        .doc(Utils.userId)
        .collection("measurements")
        .doc(data.documentID)
        .delete();

    await fetchData();
  }
}
