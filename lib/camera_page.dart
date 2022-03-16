import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'camera_model.dart';
import 'home_page.dart';

final AudioCache _cache = AudioCache();
AudioPlayer? audioPlayer;
bool? soundLoop;
bool? executeFuture;
int loopCount = 0;
int notificationCounter = 0;

class CameraPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    soundLoop = false;
    notificationCounter = 0;
    return ChangeNotifierProvider<CameraModel>(
        create: (_) => CameraModel()
          ..getCamera()
          ..startTimer(),
        builder: (context, snapshot) {
          return Scaffold(
            body: Consumer<CameraModel>(builder: (context, model, child) {
              if (model.controller == null) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "No Camera",
                        style: TextStyle(fontSize: 35),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      FloatingActionButton(
                        onPressed: () {
                          Navigator.pop(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()));
                        },
                        child: Icon(Icons.arrow_back_ios),
                      ),
                    ],
                  ),
                );
              }
              return Stack(
                children: [
                  FutureBuilder<void>(
                      future: model.initializeController,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return CustomPaint(
                            foregroundPainter: Painter(model.recognition!),
                            child: CameraPreview(
                              model.controller!,
                              child: model.predict(),
                            ),
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: FloatingActionButton(
                        onPressed: () async {
                          executeFuture = false;
                          await audioPlayer?.stop();
                          model.stopTimer();
                          //todo
                          final result = model.seconds / notificationCounter;
                          print("結果");
                          print("平均:${result}秒に1回猫背になっています");
                          //todo
                          Navigator.pop(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()));
                        },
                        child: Icon(Icons.arrow_back_ios),
                      )),
                ],
              );
            }),
          );
        });
  }
}

class Painter extends CustomPainter {
  List? params;
  bool beyond = false;
  Painter(this.params);
  @override
  void paint(Canvas canvas, Size size) async {
    final paint = Paint();
    if (params!.isNotEmpty) {
      for (var re in params!) {
        var result = re["keypoints"].values.map((k) {
          if (k["part"] == "nose" ||
              k["part"] == "leftEye" ||
              k["part"] == "rightEye" ||
              k["part"] == "leftEar" ||
              k["part"] == "rightEar") {
            paint.color = Colors.white;
            canvas.drawCircle(
                Offset(size.width * k["x"], size.height * k["y"]), 5, paint);
            if (k["part"] == "nose" && k["y"] > 0.5) {
              paint.color = Colors.red;
              paint.strokeWidth = 3;
              canvas.drawLine(Offset(0, size.height / 2),
                  Offset(size.width, size.height / 2), paint);
              beyond = true;
              NotificationSound(beyond);
            } else if (!beyond) {
              paint.color = Colors.greenAccent;
              paint.strokeWidth = 3;
              canvas.drawLine(Offset(0, size.height / 2),
                  Offset(size.width, size.height / 2), paint);
              NotificationSound(beyond);
            }
          }
        });
        print(result);
      }
    } else {
      soundLoop = false;
      executeFuture = false;
      await audioPlayer?.stop();
    }
  }

  NotificationSound(bool beyond) async {
    if (beyond && !soundLoop!) {
      soundLoop = true;
      executeFuture = true;
      loopCount++;
      if (loopCount < 2) {
        Future.delayed(const Duration(seconds: 3), () async {
          loopCount = 0;
          if (executeFuture!) {
            audioPlayer = await _cache.loop("sounds/notification.mp3");
            //デバッグモードでだけ発生するバグ対策
            executeFuture = false;
            notificationCounter++;
            print("通知回数:${notificationCounter}");
          }
        });
      }
    } else if (!beyond && soundLoop!) {
      soundLoop = false;
      executeFuture = false;
      await audioPlayer?.stop();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
