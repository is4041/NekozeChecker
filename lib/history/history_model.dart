import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../camera/camera_model.dart';
import '../data.dart';
import '../utils.dart';

class HistoryModel extends ChangeNotifier {
  bool isLoading = false;
  bool showSwitch = false;
  List<Map<String, String>> data5 = [];
  List<Data>? data = [];
  String title = "";
  String userId = firebaseAuth.currentUser!.uid;
  dynamic totalAverage;
  dynamic dailyAverage;

  Future fetchData() async {
    isLoading = true;
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('measurements')
        .where("userId", isEqualTo: userId.toString())
        .orderBy("createdAt", descending: true)
        .get();

    final data = snapshot.docs.map((doc) => Data(doc)).toList();
    this.data = data;

    isLoading = false;
    notifyListeners();
  }

  Future updateTitle(Data data) async {
    if (title.isNotEmpty) {
      final doc = FirebaseFirestore.instance
          .collection("measurements")
          .doc(data.documentID);
      await doc.update({
        "title": title,
      });
    } else {
      final doc = FirebaseFirestore.instance
          .collection("measurements")
          .doc(data.documentID);
      await doc.update({
        "title": "",
      });
    }
  }

  Future delete(Data data) async {
    return FirebaseFirestore.instance
        .collection("measurements")
        .doc(data.documentID)
        .delete();
  }
}
