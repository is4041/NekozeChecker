import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

class CameraModel extends ChangeNotifier {
  CameraController? controller;
  List<CameraDescription> cam = [];
  Future<void>? initializeController;
  bool isDetecting = false;
  List recognition = [];
  Timer? timer;
  int seconds = 0;
  int numberOfNotifications = 0;

  Future getCamera() async {
    cam = await availableCameras();
    final lastCamera = cam.last;
    controller = CameraController(lastCamera, ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.bgra8888);
    initializeController = controller?.initialize();
    notifyListeners();
  }

  startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      seconds++;
      print("${seconds}秒");
    });
  }

  stopTimer() {
    timer?.cancel();
  }

  counter() {
    numberOfNotifications++;
    print("通知回数:${numberOfNotifications}");
  }

  calculate() {
    final result = seconds / numberOfNotifications;
    print("結果");
    print("平均:${result}秒に1回猫背になっています");
  }

  predict() {
    controller?.startImageStream((CameraImage img) async {
      if (!isDetecting) {
        isDetecting = true;
        recognition = await poseEstimation(img);
        isDetecting = false;
        notifyListeners();
      }
    });
  }

  poseEstimation(CameraImage img) async {
    final results = await Tflite.runPoseNetOnFrame(
      bytesList: img.planes.map((plane) {
        return plane.bytes;
      }).toList(),
      imageHeight: img.height,
      imageWidth: img.width,
      numResults: 1,
    );
    return results;
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }
}
