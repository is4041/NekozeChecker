import 'dart:async';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:posture_correction/utils.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter/foundation.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

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

  //カメラ起動
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

  //姿勢推定
  static Future<List> poseEstimation(CameraImage img) async {
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

  //タイマー（計測時間を計る）
  startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      measuringSec++;
      print("${measuringSec}秒");
    });
  }

  stopTimer() {
    timer?.cancel();
  }

  //タイマー（姿勢不良の間だけ作動）
  startBadPostureTimer() {
    badPostureTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      measuringBadPostureSec++;
      print("猫背検知中...${measuringBadPostureSec}秒");
    });
  }

  stopBadPostureTimer() {
    badPostureTimer?.cancel();
  }

  //警告音が鳴った回数をカウント
  counter() {
    notificationCounter++;
    print("通知回数:${notificationCounter}");
  }

  //firebaseにデータを保存
  addData() async {
    final createdAt = Timestamp.now().toDate().toString().substring(0, 19);
    final userId = firebaseAuth.currentUser!.uid.toString();

    await FirebaseFirestore.instance.collection("measurements").add({
      "createdAt": createdAt,
      "measuringBadPostureSec": measuringBadPostureSec,
      "measuringSec": measuringSec,
      "memo": "",
      "notificationCounter": notificationCounter,
      "timeToNotification": Utils.timeToNotification,
      "userId": userId,
    });
  }

  //最終計測日を更新
  lastMeasuredOn() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(Utils.userId)
        .update({
      // "lastMeasuredOn": Timestamp.now().toDate().toString().substring(0, 10),
      "lastMeasuredOn": Timestamp.now(),
    });
  }

  //ダークモード切り替え
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
