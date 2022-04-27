import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';

import '../camera/camera_model.dart';
import '../utils.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;

class HomeModel extends ChangeNotifier {
  String totalAverage = "*";
  List<Data>? data = [];
  Future loadModel() async {
    Tflite.close();
    try {
      String? res;
      res = await Tflite.loadModel(
          model: "assets/posenet_mv1_075_float_from_checkpoints.tflite");
      if (kDebugMode) {
        print(res);
      }
    } on PlatformException {
      if (kDebugMode) {
        print("Failed to load model");
      }
    }
  }

  void fetchData() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('measurements').get();

    final List<Data> data = snapshot.docs.map((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
      final String seconds = data["seconds"];
      final String numberOfNotifications = data["numberOfNotifications"];
      final String average = data["averageTime"];
      final String userId = data["userId"];
      return Data(seconds, numberOfNotifications, average, userId);
    }).toList();
    this.data = data;
    notifyListeners();
  }

  getTotalAverage() async {
    final userId = firebaseAuth.currentUser!.uid;
    DocumentSnapshot snapshot = await firestore.doc("users/$userId").get();
    final data = snapshot.data() as Map<String, dynamic>;
    totalAverage = data["totalAverage"];
    print(totalAverage);
    notifyListeners();
  }
}
