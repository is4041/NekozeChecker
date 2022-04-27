import 'dart:async';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

import '../utils.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
final userId = firebaseAuth.currentUser!.uid;

class CameraModel extends ChangeNotifier {
  CameraController? controller;
  List<CameraDescription> cam = [];
  bool isDetecting = false;
  List recognition = [];
  Timer? timer;
  int seconds = 0;
  int numberOfNotifications = 0;
  dynamic averageTime = 0;
  double totalAverage = 0;

  Future getCamera() async {
    cam = await availableCameras();
    final lastCamera = cam.last;
    controller = CameraController(lastCamera, ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.bgra8888);
    await controller?.initialize();

    controller?.startImageStream((CameraImage img) async {
      // final isolate = IsolateData(cameraImage: img);
      if (!isDetecting) {
        isDetecting = true;
        // recognition = (await poseEstimation(img))!;
        recognition = await compute<CameraImage, dynamic>(poseEstimation, img);
        //todo compute
        // final result = await compute(heavyTask, 1000000000);
        // print(result);
        isDetecting = false;
        notifyListeners();
      }
    });
    notifyListeners();
  }

// compute　例
//   static String heavyTask(int value) {
//     String res = "";
//     for (int i = 0; i < value; ++i) {
//       if (i == value - 1) res = "finish";
//     }
//     return res;
//   }

  static Future<List?> poseEstimation(CameraImage img) async {
    // try {
    //   final results = await Tflite.runPoseNetOnFrame(
    //     bytesList: img.planes.map((plane) {
    //       return plane.bytes;
    //     }).toList(),
    //     imageHeight: img.height,
    //     imageWidth: img.width,
    //     numResults: 1,
    //   );
    //   return results!;
    // } catch (e) {
    //   print("1");
    //   print(e);
    //   print("2");
    //   return null;
    // }
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
      averageTime = "*";
    }
    print("平均:${averageTime}秒に1回猫背になっています");
  }

  addData() async {
    final createdAt = Timestamp.now().toDate().toString();
    final userId = firebaseAuth.currentUser!.uid.toString();

    await FirebaseFirestore.instance.collection("measurements").add({
      "createdAt": createdAt,
      "userId": userId,
      "seconds": seconds.toString(),
      "numberOfNotifications": numberOfNotifications.toString(),
      "averageTime": averageTime != "*" ? averageTime.toStringAsFixed(2) : "*",
    });
  }

  Future calculateTotalAverage() async {
    List totalSecondsArray = [];
    List totalNotificationsArray = [];
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("measurements").get();
    for (var doc in snapshot.docs) {
      if (doc.get("userId") == userId.toString()) {
        //todo 変更箇所？
        totalSecondsArray.add(double.parse(doc.get("seconds")));
        totalNotificationsArray
            .add(double.parse(doc.get("numberOfNotifications")));
      }
    }
    print("秒数：${totalSecondsArray}");
    final totalOfSeconds = totalSecondsArray.reduce((a, b) => a + b);
    print("合計秒数:${totalOfSeconds}秒");
    print("通知数：${totalNotificationsArray}");

    final totalOfNotifications =
        totalNotificationsArray.reduce((a, b) => a + b);
    print("合計通知回数:${totalOfNotifications}回");
    totalAverage = totalOfSeconds / totalOfNotifications;
    print("平均秒数:${totalAverage.round()}秒(四捨五入)");
  }

  void upDateTotalAverage() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .update({"totalAverage": totalAverage.round().toString()});
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }
}

// class IsolateData {
//   IsolateData({required this.cameraImage});
//   final CameraImage cameraImage;
// }
