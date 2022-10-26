import 'dart:async';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:posture_correction/utils.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter/foundation.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
final userId = firebaseAuth.currentUser!.uid;
final today = Timestamp.now().toDate().toString().substring(0, 10);

class CameraModel extends ChangeNotifier {
  CameraController? controller;
  List<CameraDescription> cam = [];
  bool isDetecting = false;
  List recognition = [];
  Timer? timer;
  int seconds = 0;
  int numberOfNotifications = 0;
  dynamic averageTime = 0;
  dynamic totalAverage;
  dynamic dailyAverage;

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
        // recognition = await compute(poseEstimation, img);
        isDetecting = false;
        notifyListeners();
      }
    });
    notifyListeners();
  }

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
    if (numberOfNotifications > 0) {
      averageTime = seconds / numberOfNotifications / 60;
      //ここに"measuringTime(m:s)"(文字列の連結必要)
      //measuringSec = seconds ~/ 60;
      //measuringMin = seconds % 60;
      //final www = measuringMin.toString(); + : + measuringSec.toString();
    } else {
      averageTime = "";
    }
    print("平均:${averageTime}分に1回猫背になっています");
  }

  addData() async {
    final createdAt = Timestamp.now().toDate().toString().substring(0, 19);
    final userId = firebaseAuth.currentUser!.uid.toString();

    await FirebaseFirestore.instance.collection("measurements").add({
      "createdAt": createdAt,
      "userId": userId,
      "measuringSec": seconds.toString(),
      "numberOfNotifications": numberOfNotifications.toString(),
      "averageMin": averageTime != "" ? averageTime.toStringAsFixed(2) : "",
    });
  }

  Future calculateTotalAverage() async {
    List totalSecondsArray = [];
    List totalNotificationsArray = [];
    List dailyTotalSecondsArray = [];
    List dailyTotalNotificationsArray = [];
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("measurements").get();
    for (var doc in snapshot.docs) {
      if (doc.get("userId") == userId.toString()) {
        //当日の計測（秒数、警告回数）を配列に追加
        if (doc.get("createdAt").toString().substring(0, 10) == today) {
          dailyTotalSecondsArray.add(double.parse(doc.get("measuringSec")));
          dailyTotalNotificationsArray
              .add(double.parse(doc.get("numberOfNotifications")));
        }
        //全データの計測（秒数、警告回数）を配列に追加
        totalSecondsArray.add(double.parse(doc.get("measuringSec")));
        totalNotificationsArray
            .add(double.parse(doc.get("numberOfNotifications")));
      }
    }
    //当日の計測データ（秒数、警告回数）がisNotEmptyでなければそれぞれのデータの合計値を割り出す
    if (dailyTotalSecondsArray.isNotEmpty &&
        dailyTotalNotificationsArray.isNotEmpty) {
      print("本日の計測秒数リスト: $dailyTotalSecondsArray");
      print("本日の警告回数リスト: $dailyTotalNotificationsArray");
      final totalOfDailySeconds =
          dailyTotalSecondsArray.reduce((a, b) => a + b);
      print("本日の計測秒数の総計: $totalOfDailySeconds");

      final totalOfDailyNotifications =
          dailyTotalNotificationsArray.reduce((a, b) => a + b);
      print("本日の警告回数の総計: $totalOfDailyNotifications");
      //当日の計測データの平均値を割り出す（計測時間÷警告回数＝何秒に一度警告されたか）
      if (totalOfDailyNotifications > 0) {
        dailyAverage = totalOfDailySeconds / totalOfDailyNotifications / 60;
        print("本日の平均:${dailyAverage.round()}分(四捨五入)");
        //警告回数が0なら計算不可のため＊を代入
      } else {
        dailyAverage = "";
      }
      //データなしでは計算不可のため＊を代入
    } else {
      dailyAverage = "";
    }
    //上記の全データver
    if (totalSecondsArray.isNotEmpty && totalNotificationsArray.isNotEmpty) {
      print("全ての計測秒数リスト: $totalSecondsArray");
      print("全ての警告回数リスト: $totalNotificationsArray");
      final totalOfSeconds = totalSecondsArray.reduce((a, b) => a + b);
      print("全ての計測秒数の総計: $totalOfSeconds");

      final totalOfNotifications =
          totalNotificationsArray.reduce((a, b) => a + b);
      print("全ての警告回数の総計: $totalOfNotifications");
      if (totalOfNotifications > 0) {
        totalAverage = totalOfSeconds / totalOfNotifications / 60;
        print("全体の平均:${totalAverage.round()}分(四捨五入)");
      } else {
        totalAverage = "";
      }
    } else {
      totalAverage = "";
    }
  }

  upDateTotalAverage() async {
    await FirebaseFirestore.instance.collection("users").doc(userId).update({
      "dailyAverage":
          dailyAverage.toString() != "" ? dailyAverage.round().toString() : "",
      "totalAverage":
          totalAverage.toString() != "" ? totalAverage.round().toString() : ""
    });

    if (dailyAverage.toString() != "") {
      Utils.dailyAverage = dailyAverage.round().toString();
    } else {
      Utils.dailyAverage = dailyAverage;
    }

    if (totalAverage.toString() != "") {
      Utils.totalAverage = totalAverage.round().toString();
    } else {
      Utils.totalAverage = totalAverage;
    }
  }

  lastMeasuredOn() async {
    await FirebaseFirestore.instance.collection("users").doc(userId).update({
      "lastMeasuredOn": Timestamp.now().toDate().toString().substring(0, 10),
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }
}
