import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';

import '../data.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;

class HomeModel extends ChangeNotifier {
  dynamic totalAverage = "＊";

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

  getTotalAverage() async {
    final userId = firebaseAuth.currentUser!.uid;
    DocumentSnapshot snapshot = await firestore.doc("users/$userId").get();
    final data = snapshot.data() as Map<String, dynamic>;
    totalAverage = data["totalAverage"];
    print("結果");
    print(totalAverage);
    notifyListeners();
  }
}
