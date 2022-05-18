import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'camera_model.dart';
import '../home/home_page.dart';

final AudioCache _cache = AudioCache();
AudioPlayer? audioPlayer;
bool soundLoop = false;
bool? executeFuture;
int loopCount = 0;
bool detection = false;
bool? isCounting;
bool? isAdjusting;

class CameraPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    isAdjusting = true;
    isCounting = false;
    return ChangeNotifierProvider<CameraModel>(
        create: (_) => CameraModel()..getCamera(),
        builder: (context, snapshot) {
          return Scaffold(
            body: Consumer<CameraModel>(builder: (context, model, child) {
              if (model.controller == null) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Camera is not available",
                        style: TextStyle(fontSize: 35),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      FloatingActionButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Icon(Icons.arrow_back_ios),
                      ),
                    ],
                  ),
                );
              }
              return Stack(
                children: [
                  CustomPaint(
                    foregroundPainter: Painter(model.recognition, model),
                    child: CameraPreview(
                      model.controller!,
                    ),
                  ),
                  Align(
                      alignment: const Alignment(0, 0.9),
                      child: FloatingActionButton(
                        onPressed: () async {
                          isCounting = false;
                          isAdjusting = false;
                          executeFuture = false;
                          await audioPlayer?.stop();
                          model.stopTimer();
                          model.calculate();
                          if (model.seconds > 300) {
                            await model.addData();
                            await model.calculateTotalAverage();
                            await model.upDateTotalAverage();
                            await model.lastMeasuredOn();
                          } else {
                            await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("使用時間が5分未満ですがデータを保存しますか？"),
                                    actions: [
                                      TextButton(
                                        child: const Text("ok"),
                                        onPressed: () async {
                                          await model.addData();
                                          await model.calculateTotalAverage();
                                          await model.upDateTotalAverage();
                                          await model.lastMeasuredOn();
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text("cancel"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  );
                                });
                          }

                          Navigator.of(context).pop([
                            model.averageTime.toString(),
                            model.seconds.toString(),
                            model.numberOfNotifications.toString()
                          ]);
                        },
                        child: const Icon(Icons.stop),
                        backgroundColor: Colors.red,
                      )),
                  if (!isCounting! && isAdjusting!)
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.grey.withOpacity(0.5),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "位置・音量を\n調整してください",
                              style:
                                  TextStyle(fontSize: 30, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "（okを押すと計測が始まります）",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                            const SizedBox(
                              height: 150,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                    onPressed: () async {
                                      executeFuture = false;
                                      await audioPlayer?.stop();
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("戻る")),
                                ElevatedButton(
                                    onPressed: () {
                                      isCounting = true;
                                    },
                                    child: Text("ok")),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  if (isCounting! && !detection)
                    Center(
                        child: Text(
                      "計測停止中",
                      style: TextStyle(fontSize: 30, color: Colors.white),
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
  final CameraModel model;
  bool beyond = false;
  Painter(this.params, this.model);
  @override
  void paint(Canvas canvas, Size size) async {
    final paint = Paint();
    if (params!.isNotEmpty) {
      if (isCounting! && !detection) {
        detection = true;
        model.startTimer();
        print("Timer Start");
      }
      for (var re in params!) {
        re["keypoints"].values.forEach((k) {
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
              // if (isCounting!) {
              notificationSound(beyond);
              // }
            } else if (!beyond) {
              paint.color = Colors.greenAccent;
              paint.strokeWidth = 3;
              canvas.drawLine(Offset(0, size.height / 2),
                  Offset(size.width, size.height / 2), paint);
              // if (isCounting!) {
              notificationSound(beyond);
              // }
            }
          }
        });
      }
    } else if (detection) {
      detection = false;
      print("検知不可");
      soundLoop = false;
      executeFuture = false;
      model.stopTimer();
      print("Timer Stop");
      await audioPlayer?.stop();
    }
  }

  notificationSound(bool beyond) async {
    if (beyond && !soundLoop) {
      soundLoop = true;
      executeFuture = true;
      loopCount++;
      if (loopCount < 2) {
        Future.delayed(const Duration(seconds: 5), () async {
          loopCount = 0;
          if (executeFuture!) {
            audioPlayer = await _cache.loop("sounds/notification.mp3");
            executeFuture = false;
            if (isCounting!) {
              model.counter();
            }
          }
        });
      }
    } else if (!beyond && soundLoop) {
      soundLoop = false;
      executeFuture = false;
      await audioPlayer?.stop();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
