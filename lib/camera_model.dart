import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';

class CameraModel extends ChangeNotifier {
  List<CameraDescription> cam = [];
  Future<void>? initializeController;

  CameraController? controller;
  Future getCamera() async {
    cam = await availableCameras();
    final lastCamera = cam.last;
    controller = CameraController(
      lastCamera,
      ResolutionPreset.high,
    );
    initializeController = controller?.initialize();
    notifyListeners();
  }
}
