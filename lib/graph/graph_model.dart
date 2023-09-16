import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';

import '../utils.dart';

int monthCounter = 0;

class GraphModel extends ChangeNotifier {
  bool isLoading = false;
  double rateOfGoodPosture = 0;

  List<Map<String, dynamic>> data = [];

  final now = DateTime.now();
  String? year;
  String? month;

  List<FlSpot> spots1 = [];
  List<FlSpot> spots2 = [];
  double num = 0;
  double max = 0;
  bool extendWidth = false;
  bool switchWidthIcon = false;
  bool show = false;
  bool dotSwitch = false;
  bool _processing = false;

  //当月の計測データをfirebaseから取得、配列化する
  Future<void> fetchGraphData() async {
    List arrayOfMonthMeasuringSec = [];
    List arrayOfMonthMeasuringBadSec = [];
    rateOfGoodPosture = 0;
    isLoading = true;
    spots1 = [];
    spots2 = [];
    data = [];
    num = 0;
    max = 0;
    final getMonth =
        DateTime(now.year, now.month + monthCounter).toString().substring(0, 7);
    year = getMonth.substring(0, 4);
    month = getMonth.substring(5, 7);

    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(Utils.userId)
        .collection("measurements")
        .orderBy("createdAt", descending: false)
        .get();

    for (var doc in snapshot.docs) {
      if (doc.get("createdAt").toString().substring(0, 7) == getMonth) {
        arrayOfMonthMeasuringSec.add(doc.get("measuringSec"));
        arrayOfMonthMeasuringBadSec.add(doc.get("measuringBadPostureSec"));

        //姿勢良好の時間と姿勢不良の時間の割合を算出する
        if (arrayOfMonthMeasuringSec.isNotEmpty) {
          final totalOfMonthMeasuringSec =
              arrayOfMonthMeasuringSec.reduce((a, b) => a + b);
          final totalOfMonthBadPostureSec =
              arrayOfMonthMeasuringBadSec.reduce((a, b) => a + b);
          final totalOfMonthGoodPostureSec =
              totalOfMonthMeasuringSec - totalOfMonthBadPostureSec;
          rateOfGoodPosture = double.parse(
              ((totalOfMonthGoodPostureSec / totalOfMonthMeasuringSec) * 100)
                  .toStringAsFixed(1));
        }

        final createdAt = await doc.get("createdAt").substring(0, 10);
        final measuringSec = await doc.get("measuringSec");
        final measuringBadPostureSec = await doc.get("measuringBadPostureSec");
        final measuringGoodPostureSec = measuringSec - measuringBadPostureSec;

        //グラフを表示する際の処理負荷軽減のため計測秒数を 1/60 （分）に変換
        final measuringMin = double.parse(measuringSec.toString()) / 60;
        final measuringBadPostureMin =
            double.parse(measuringBadPostureSec.toString()) / 60;
        final flSpot1 = FlSpot(num + 1, measuringMin);
        final flSpot2 = FlSpot(num + 1, measuringBadPostureMin);

        num++;
        spots1.add(flSpot1);
        spots2.add(flSpot2);
        show = true;

        data.add({
          "createdAt": createdAt,
          "measuringSec": measuringSec,
          "measuringBadPostureSec": measuringBadPostureSec,
          "measuringGoodPostureSec": measuringGoodPostureSec,
        });
      }
    }

    data = List.from(data.reversed);

    //グラフのy軸の最大値（計測時間が最も長いデータ）を取得
    for (int i = 0; i < spots1.length; i++) {
      double v = spots1[i].y;
      if (v > max) {
        max = v;
      }
    }
    isLoading = false;
    notifyListeners();
  }

  //先月のデータを取得
  void getLastMonthData() async {
    if (_processing) return;
    _processing = true;
    monthCounter--;
    await fetchGraphData();
    _processing = false;
  }

  //翌月のデータを取得（当月のデータ表示中は押下不可）
  void getNextMonthData() async {
    if (_processing) return;
    _processing = true;
    monthCounter++;
    await fetchGraphData();
    _processing = false;
  }

  //グラフの表示変更
  void changes() {
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
