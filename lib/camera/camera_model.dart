import 'dart:async';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:posture_correction/utils.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter/foundation.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
final today = Timestamp.now().toDate().toString().substring(0, 10);

class CameraModel extends ChangeNotifier {
  CameraController? controller;
  List<CameraDescription> cam = [];
  bool isDetecting = false;
  List recognition = [];
  Timer? timer;
  Timer? badPostureTimer;
  num measuringSec = 0;
  num measuringBadPostureSec = 0;
  int notificationCounter = 0;
  bool darkMode = false;

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
        //todo compute
        // recognition = await compute(poseEstimation, img);
        isDetecting = false;
        notifyListeners();
      }
    });
    notifyListeners();
  }

  static Future<List> poseEstimation(CameraImage img) async {
    //todo var result
    final results = await Tflite.runPoseNetOnFrame(
      bytesList: img.planes.map((plane) {
        return plane.bytes;
      }).toList(),
      imageHeight: img.height,
      imageWidth: img.width,
      numResults: 1,
    );
    return results!;
  }

  startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      measuringSec++;
      print("${measuringSec}秒");
    });
  }

  stopTimer() {
    timer?.cancel();
  }

  startBadPostureTimer() {
    badPostureTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      measuringBadPostureSec++;
      print("猫背検知中...${measuringBadPostureSec}秒");
    });
  }

  stopBadPostureTimer() {
    badPostureTimer?.cancel();
  }

  counter() {
    notificationCounter++;
    print("通知回数:${notificationCounter}");
  }

  addData() async {
    final createdAt = Timestamp.now().toDate().toString().substring(0, 19);
    final userId = firebaseAuth.currentUser!.uid.toString();
    final measuringMin = double.parse((measuringSec / 60).toStringAsFixed(1));
    final measuringBadPostureMin =
        double.parse((measuringBadPostureSec / 60).toStringAsFixed(1));

    await FirebaseFirestore.instance.collection("measurements").add({
      "createdAt": createdAt,
      // "measuringBadPostureMin": measuringBadPostureMin,
      "measuringBadPostureSec": measuringBadPostureSec,
      // "measuringMin": measuringMin,
      "measuringSec": measuringSec,
      "notificationCounter": notificationCounter,
      "timeToNotification": Utils.timeToNotification,
      "title": "",
      "userId": userId,
    });
  }

  lastMeasuredOn() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(Utils.userId)
        .update({
      "lastMeasuredOn": Timestamp.now().toDate().toString().substring(0, 10),
    });
  }

  getScreenMode() async {
    if (darkMode == false) {
      darkMode = true;
    } else {
      darkMode = false;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }
}
