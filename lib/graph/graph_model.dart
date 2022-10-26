import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';

import '../camera/camera_model.dart';
import 'graph_page.dart';

class GraphModel extends ChangeNotifier {
  // bool show = true;
  double num = 0;
  List<FlSpot> spots = [];

  void fetchGraphData() async {
    // show = true;
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('measurements')
        .orderBy("createdAt", descending: false)
        .get();
    for (var doc in snapshot.docs) {
      if (doc.get("userId") != userId.toString()) {
        return null;
      }
      final averageTime = await doc.get("averageMin");
      if (averageTime != "") {
        final flSpot = FlSpot(num, double.parse(averageTime));
        num++;
        spots.add(flSpot);
        print(flSpot);
      }
    }

    print("終了");
    notifyListeners();
  }
}
