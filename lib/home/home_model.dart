import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';

import '../camera/camera_model.dart';
import '../data.dart';
import '../utils.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

class HomeModel extends ChangeNotifier {
  Future loadModel() async {
    Tflite.close();
    try {
      String? res;
      res = await Tflite.loadModel(
        model: "assets/posenet_mv1_075_float_from_checkpoints.tflite",
      );
      print(res);
    } on PlatformException {
      print("Failed to load model");
    }
  }

  getAverage() async {
    final today = Timestamp.now().toDate().toString().substring(0, 10);

    DocumentSnapshot snapshot = await firestore.doc("users/$userId").get();
    final data = snapshot.data() as Map<String, dynamic>;

    if (today == data["lastMeasuredOn"]) {
      Utils.dailyAverage = data["dailyAverage"];
    } else {
      await upDateDailyAverage();
      Utils.dailyAverage = "";
    }

    if (Utils.totalAverage == null) {
      DocumentSnapshot snapshot = await firestore.doc("users/$userId").get();
      final data = snapshot.data() as Map<String, dynamic>;

      Utils.totalAverage = data["totalAverage"];
    }
    notifyListeners();
  }

  upDateDailyAverage() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .update({"dailyAverage": ""});
  }
}
