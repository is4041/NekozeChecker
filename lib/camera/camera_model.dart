import 'dart:async';
import 'dart:ui';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:posture_correction/camera/camera_page.dart';
import 'package:posture_correction/utils.dart';
import 'package:flutter/foundation.dart';

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

  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? customPaint;
  var _cameraLensDirection = CameraLensDirection.back;

  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());

  //カメラ起動
  // Future getCamera() async {
  //   cam = await availableCameras();
  //   final lastCamera = cam.last;
  //   controller = CameraController(lastCamera, ResolutionPreset.high,
  //       imageFormatGroup: ImageFormatGroup.bgra8888);
  //   await controller?.initialize();
  //
  //   controller?.startImageStream((CameraImage img) async {
  //     if (!isDetecting) {
  //       isDetecting = true;
  //       // recognition = await poseEstimation(img);
  //       isDetecting = false;
  //       notifyListeners();
  //     }
  //   });
  //   notifyListeners();
  // }

  //姿勢推定
  // static Future<List> poseEstimation(CameraImage img) async {
  //   final results = await Tflite.runPoseNetOnFrame(
  //     bytesList: img.planes.map((plane) {
  //       return plane.bytes;
  //     }).toList(),
  //     imageHeight: img.height,
  //     imageWidth: img.width,
  //     numResults: 1,
  //   );
  //   return results!;
  // }

  //todo 修正ver
  Future getCamera() async {
    cam = await availableCameras();
    final lastCamera = cam.last;
    controller = CameraController(lastCamera, ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.bgra8888);
    await controller?.initialize();

    await controller?.startImageStream(processCameraImage);

    notifyListeners();
  }

  void processCameraImage(CameraImage image) {
    final inputImage = inputImageFromCameraImage(image);
    if (inputImage == null) return;
    processImage(inputImage);
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    final poses = await _poseDetector.processImage(inputImage);
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = PosePainter(
        poses,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      customPaint = CustomPaint(painter: painter);
    }
    _isBusy = false;
    notifyListeners();
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
  }

  //firebaseにデータを保存
  addData() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none || Utils.userId.isEmpty) {
      throw ("通信状態をご確認ください");
    }
    final createdAt = Timestamp.now().toDate().toString().substring(0, 19);

    await FirebaseFirestore.instance
        .collection("users")
        .doc(Utils.userId)
        .collection("measurements")
        .add({
      "createdAt": createdAt,
      "measuringBadPostureSec": measuringBadPostureSec,
      "measuringSec": measuringSec,
      "memo": "",
      "notificationCounter": notificationCounter,
      "timeToNotification": Utils.timeToNotification,
    });

    await lastMeasuredOn();
  }

  //最終計測日を更新
  lastMeasuredOn() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(Utils.userId)
        .update({
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

  InputImage? inputImageFromCameraImage(CameraImage image) {
    if (controller == null) return null;

    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/android/src/main/java/com/google_mlkit_commons/InputImageConverter.java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/ios/Classes/MLKVisionImage%2BFlutterPlugin.m
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/lib/vision_detector_views/painters/coordinates_translator.dart
    final camera = cam[1];
    final sensorOrientation = camera.sensorOrientation;
    // print(
    //     'lensDirection: ${camera.lensDirection}, sensorOrientation: $sensorOrientation, ${_controller?.value.deviceOrientation} ${_controller?.value.lockedCaptureOrientation} ${_controller?.value.isCaptureOrientationLocked}');
    InputImageRotation? rotation;
    rotation = InputImageRotationValue.fromRawValue(sensorOrientation);

    if (rotation == null) return null;
    // print('final rotation: $rotation');

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }
}
