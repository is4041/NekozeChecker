import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';

import '../camera/camera_model.dart';
import '../data.dart';
import 'graph_page.dart';
import 'dart:math';

int monthCounter = 0;

class GraphModel extends ChangeNotifier {
  String userId = firebaseAuth.currentUser!.uid;

  List<Map<String, String>> data1 = [];
  List<Map<String, String>> data2 = [];

  final now = DateTime.now();
  String? month;

  List<FlSpot> spots1 = [];
  List<FlSpot> spots2 = [];
  double num = 1;
  double max = 0;
  bool extendHeight = true;
  bool extendWidth = false;
  bool switchHeightIcon = false;
  bool switchWidthIcon = false;
  bool show = false;
  bool dotSwitch = false;

  void fetchGraphData() async {
    spots1 = [];
    spots2 = [];
    data1 = [];
    num = 1;
    max = 0;
    final getMonth =
        DateTime(now.year, now.month + monthCounter).toString().substring(0, 7);
    month = getMonth;

    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('measurements')
        .orderBy("createdAt", descending: false)
        .get();

    for (var doc in snapshot.docs) {
      // if (doc.get("userId") == userId.toString()) {
      if (doc.get("createdAt").toString().substring(0, 7) == getMonth) {
        final createdAt = await doc.get("createdAt").substring(0, 10);
        final measuringMin = await doc.get("measuringMin");
        final measuringBadPostureMin = await doc.get("measuringBadPostureMin");
        if (measuringMin != "") {
          final flSpot1 = FlSpot(num, double.parse(measuringMin));
          final flSpot2 = FlSpot(num, double.parse(measuringBadPostureMin));
          num++;
          spots1.add(flSpot1);
          spots2.add(flSpot2);
          show = true;
          data1.add({
            "createdAt": createdAt,
            "measuringMin": measuringMin,
            "measuringBadPostureMin": measuringBadPostureMin
          });
        } else {
          //todo
          data2.add({"createdAt": createdAt, "measuringMin": "なし"});
        }
      }
      // }
    }

    for (int i = 0; i < spots1.length; i++) {
      double v = spots1[i].y;
      if (v > max) {
        max = v;
      }
    }

    notifyListeners();
  }

  void getLastMonthData() async {
    monthCounter--;
    fetchGraphData();
  }

  void getNextMonthData() async {
    monthCounter++;
    fetchGraphData();
  }

  // changes() {
  //   if (extendHeight == false) {
  //     extendHeight = true;
  //     switchHeightIcon = false;
  //   } else {
  //     extendHeight = false;
  //     switchHeightIcon = true;
  //   }
  //   notifyListeners();
  // }

  changes2() {
    if (extendWidth == false) {
      extendWidth = true;
      switchWidthIcon = true;
      dotSwitch = true;
    } else {
      extendWidth = false;
      switchWidthIcon = false;
      dotSwitch = false;
    }
    notifyListeners();
  }
}
