import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:posture_correction/utils.dart';
import 'package:provider/provider.dart';

import 'camera_model.dart';
import '../home/home_page.dart';

final AudioCache _cache = AudioCache();
AudioPlayer? audioPlayer;
bool? soundLoop;
bool detection = false;
bool? isCounting;
bool? isAdjusting;
bool? hiddenOkButton;
Timer? notificationTimer;

class CameraPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    soundLoop = false;
    isAdjusting = true;
    isCounting = false;
    hiddenOkButton = true;
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
                        notificationTimer?.cancel();
                        await audioPlayer?.stop();
                        isCounting = false;
                        model.stopTimer();
                        model.stopBadPostureTimer();
                        model.calculate();
                        if (model.measuringSec > 300) {
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
                          model.measuringSec.toString(),
                          model.numberOfNotifications.toString()
                        ]);
                      },
                      child: const Icon(Icons.stop),
                      backgroundColor: Colors.red,
                    ),
                  ),
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
                                      notificationTimer?.cancel();
                                      await audioPlayer?.stop();
                                      Navigator.of(context).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.green,
                                    ),
                                    child: Text("戻る")),
                                ElevatedButton(
                                    onPressed: hiddenOkButton == false
                                        ? () {
                                            isAdjusting = false;
                                            isCounting = true;
                                          }
                                        : () {},
                                    style: ElevatedButton.styleFrom(
                                      primary: hiddenOkButton == false
                                          ? Colors.green
                                          : Colors.green.withOpacity(0.3),
                                    ),
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
      //okボタン押下で計測を開始（ボタン押下前からの計測開始をを阻止する）
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
              hiddenOkButton = false;
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
      notificationTimer?.cancel();
      detection = false;
      print("計測停止中");
      soundLoop = false;
      model.stopTimer();
      print("Timer Stop");
      model.stopBadPostureTimer();
      print("Bad Posture Timer Stop");
      await audioPlayer?.stop();
    }
  }

  notificationSound(bool beyond) async {
    //中央ライン以下の時の処理
    if (beyond && !soundLoop!) {
      soundLoop = true;
      hiddenOkButton = true;
      if (isCounting!) {
        model.startBadPostureTimer();
        print("猫背タイマースタート");
      }
      print("${Utils.timeToNotification}秒後警告");

      notificationTimer =
          Timer(Duration(seconds: Utils.timeToNotification), () async {
        audioPlayer = await _cache.loop("sounds/notification.mp3");
        if (isCounting!) {
          model.counter();
        }
      });
      //中央ライン以上の時の処理
    } else if (!beyond && soundLoop!) {
      soundLoop = false;
      hiddenOkButton = false;
      model.stopBadPostureTimer();
      notificationTimer?.cancel();
      await audioPlayer?.stop();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
