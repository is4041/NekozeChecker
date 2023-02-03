import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:posture_correction/utils.dart';

import '../camera/camera_model.dart';
import '../data.dart';
import 'graph_page.dart';
import 'dart:math';

int monthCounter = 0;

class GraphModel extends ChangeNotifier {
  String userId = firebaseAuth.currentUser!.uid;
  bool isLoading = false;
  double rateOfGoodPosture = 0;

  List<Map<String, dynamic>> data = [];

  final now = DateTime.now();
  String? year;
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

  Future fetchGraphData() async {
    rateOfGoodPosture = 0;
    isLoading = true;
    spots1 = [];
    spots2 = [];
    data = [];
    num = 1;
    max = 0;
    final getMonth =
        DateTime(now.year, now.month + monthCounter).toString().substring(0, 7);
    year = getMonth.substring(0, 4);
    month = getMonth.substring(5, 7);

    List arrayOfMonthMeasuringMin = [];
    List arrayOfMonthMeasuringBadMin = [];

    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('measurements')
        .where("userId", isEqualTo: userId.toString())
        .orderBy("createdAt", descending: false)
        .get();

    for (var doc in snapshot.docs) {
      if (doc.get("createdAt").toString().substring(0, 7) == getMonth) {
        arrayOfMonthMeasuringMin.add(doc.get("measuringMin"));
        arrayOfMonthMeasuringBadMin.add(doc.get("measuringBadPostureMin"));

        if (arrayOfMonthMeasuringMin.isNotEmpty) {
          final totalOfMonthMeasuringMin =
              arrayOfMonthMeasuringMin.reduce((a, b) => a + b);
          final totalOfMonthBadPostureMin =
              arrayOfMonthMeasuringBadMin.reduce((a, b) => a + b);
          final totalOfMonthGoodPostureMin =
              totalOfMonthMeasuringMin - totalOfMonthBadPostureMin;
          rateOfGoodPosture = double.parse(
              ((totalOfMonthGoodPostureMin / totalOfMonthMeasuringMin) * 100)
                  .toStringAsFixed(1));
        }

        final createdAt = await doc.get("createdAt").substring(0, 10);
        final measuringSec = doc.get("measuringSec");
        final measuringBadPostureSec = doc.get("measuringBadPostureSec");
        final measuringGoodPostureSec = measuringSec - measuringBadPostureSec;

        final measuringMin =
            double.parse(doc.get("measuringMin").toStringAsFixed(1));
        final measuringBadPostureMin =
            double.parse(doc.get("measuringBadPostureMin").toStringAsFixed(1));
        // measuringMin,measuringBadPostureMinが整数でエラー発生（toStringAsFixed必須）
        final flSpot1 = FlSpot(num, measuringMin);
        final flSpot2 = FlSpot(num, measuringBadPostureMin);

        num++;
        spots1.add(flSpot1);
        spots2.add(flSpot2);
        show = true;

        data.add({
          "createdAt": createdAt,
          "measuringSec": measuringSec,
          "measuringGoodPostureSec": measuringGoodPostureSec,
          "measuringBadPostureSec": measuringBadPostureSec,
        });
      }
    }

    for (var doc in snapshot.docs) {
      if (doc.get("createdAt").toString().substring(0, 7) == getMonth) {}
    }

    for (int i = 0; i < spots1.length; i++) {
      double v = spots1[i].y;
      if (v > max) {
        max = v;
      }
    }
    isLoading = false;
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

  changes() {
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
