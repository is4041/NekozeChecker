import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';

class HomeModel extends ChangeNotifier {
  Future loadmodel() async {
    Tflite.close();
    try {
      String? res;
      res = await Tflite.loadModel(
          model: "assets/posenet_mv1_075_float_from_checkpoints.tflite");
      print(res);
    } on PlatformException {
      print("Failed to load model");
    }
  }
}
