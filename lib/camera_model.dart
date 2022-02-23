import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:tflite/tflite.dart';

class CameraModel extends ChangeNotifier {
  CameraController? controller;
  List<CameraDescription> cam = [];
  Future<void>? initializeController;
  bool isDetecting = false;
  List? recognition = [];

  Future getCamera() async {
    cam = await availableCameras();
    final lastCamera = cam.last;
    controller = CameraController(lastCamera, ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.bgra8888);
    initializeController = controller?.initialize();
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

  predict() {
    controller?.startImageStream((CameraImage img) async {
      if (!isDetecting) {
        isDetecting = true;
        recognition = await poseEstimation(img);
        if (recognition == null) {
          throw Exception("Invalid prediction result");
        }
        if (recognition?.length != null) {
          notifyListeners();
        } else {
          if (kDebugMode) {
            print("no information");
          }
        }
        isDetecting = false;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }
}
