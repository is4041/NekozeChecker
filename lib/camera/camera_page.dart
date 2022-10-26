import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'camera_model.dart';
import '../home/home_page.dart';

final AudioCache _cache = AudioCache();
AudioPlayer? audioPlayer;
bool? soundLoop;
bool detection = false;
bool? isCounting;
bool? isAdjusting;
bool? fiveSec = false;
Timer? timer;

class CameraPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    soundLoop = false;
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
                          timer?.cancel();
                          await audioPlayer?.stop();
                          isCounting = false;
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
                          await audioPlayer?.stop();

                          Navigator.of(context).pop([
                            model.averageTime.toStringAsFixed(2),
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
                              "（OKを押すと計測が始まります）",
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
                                      timer?.cancel();
                                      await audioPlayer?.stop();
                                      Navigator.of(context).pop();
                                      print(detection);
                                    },
                                    child: Text("戻る")),
                                ElevatedButton(
                                    onPressed: () {
                                      isAdjusting = false;
                                      isCounting = true;
                                    },
                                    child: Text("OK")),
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
            //noseのkeypointsが中央ライン以下にあるとき
            if (k["part"] == "nose" && k["y"] > 0.5) {
              paint.color = Colors.red;
              paint.strokeWidth = 3;
              canvas.drawLine(Offset(0, size.height / 2),
                  Offset(size.width, size.height / 2), paint);
              beyond = true;
              notificationSound(beyond);
              //noseのkeypointsが中央ライン以上にあるとき
            } else if (!beyond) {
              paint.color = Colors.greenAccent;
              paint.strokeWidth = 3;
              canvas.drawLine(Offset(0, size.height / 2),
                  Offset(size.width, size.height / 2), paint);
              notificationSound(beyond);
            }
          }
        });
      }
      //顔認識できない場合の処理
    } else if (detection || isAdjusting!) {
      timer?.cancel();
      detection = false;
      print("計測停止中");
      soundLoop = false;
      await model.stopTimer();
      print("Timer Stop");
      await audioPlayer?.stop();
    }
  }

  notificationSound(bool beyond) async {
    //中央ライン以下の時の処理
    if (beyond && !soundLoop!) {
      soundLoop = true;
      print("5秒後警告");
      timer = Timer(Duration(seconds: 5), () async {
        fiveSec = true;
        await model.stopTimer();
        audioPlayer = await _cache.loop("sounds/notification.mp3");
        if (isCounting!) {
          await model.counter();
        }
      });
      //中央ライン以上の時の処理
    } else if (!beyond && soundLoop!) {
      soundLoop = false;
      print("AlertCancel");
      if (fiveSec == true) {
        fiveSec = false;
        await model.startTimer();
      }

      timer?.cancel();
      await audioPlayer?.stop();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
