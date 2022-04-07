import 'dart:async';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  double averageTime = 0;

  Future getCamera() async {
    cam = await availableCameras();
    final lastCamera = cam.last;
    controller = CameraController(lastCamera, ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.bgra8888);
    await controller?.initialize();
    controller?.startImageStream((CameraImage img) async {
      if (!isDetecting) {
        isDetecting = true;
        recognition = await poseEstimation(img);
        isDetecting = false;
        notifyListeners();
      }
    });
    notifyListeners();
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
    if (numberOfNotifications != 0) {
      averageTime = seconds / numberOfNotifications;
    } else {
      averageTime = seconds.toDouble();
    }
    print("平均:${averageTime}秒に1回猫背になっています");
  }

  addData() async {
    await FirebaseFirestore.instance.collection("measurements").add({
      "seconds": seconds.toString(),
      "numberOfNotifications": numberOfNotifications.toString(),
      "averageTime": averageTime.toString(),
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }
}
