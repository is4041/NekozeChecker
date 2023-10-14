import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:posture_correction/utils.dart';

import '../data.dart';

class HistoryModel extends ChangeNotifier {
  bool isLoading = false;
  List<Data>? data = [];
  String memo = "";

  //データ取得
  Future<void> fetchData() async {
    if (FirebaseAuth.instance.currentUser == null) return;
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return;
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
  Future<void> updateTitle(Data data) async {
    if (FirebaseAuth.instance.currentUser == null) return;
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return;
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
  Future<void> delete(Data data) async {
    if (FirebaseAuth.instance.currentUser == null) {
      throw ("エラーが発生しました。一度アプリを再起動してください。");
    }
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw ("削除に失敗しました。通信状態をご確認ください");
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
