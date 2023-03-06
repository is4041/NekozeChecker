import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
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
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "カメラが使用出来ません。",
                          style: TextStyle(fontSize: 25),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "端末の設定からこのアプリ（Posture correction）の\nカメラの設定をオンにしてください。",
                          // style: TextStyle(fontSize: 25),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          height: 50,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                                primary: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                            child: Text(
                              "戻る",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                              // style: TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                      onPressed: model.measuringSec > 0
                          ? () async {
                              notificationTimer?.cancel();
                              await audioPlayer?.stop();
                              isCounting = false;
                              model.stopTimer();
                              model.stopBadPostureTimer();
                              if (model.measuringSec > 300) {
                                await model.addData();
                                await model.lastMeasuredOn();
                              } else {
                                await showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return CupertinoAlertDialog(
                                        title:
                                            Text("計測時間が5分未満ですが\nデータを保存しますか？"),
                                        actions: [
                                          TextButton(
                                            child: Text(
                                              "保存しない",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: const Text("保存"),
                                            onPressed: () async {
                                              await model.addData();
                                              await model.lastMeasuredOn();
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    });
                              }
                              await audioPlayer?.stop();

                              Navigator.of(context).pop([
                                //計測時間
                                model.measuringSec,
                                //姿勢(良)の時間
                                model.measuringSec -
                                    model.measuringBadPostureSec,
                                //姿勢(不良)の時間
                                model.measuringBadPostureSec,
                                //猫背通知回数
                                model.notificationCounter.toString(),
                              ]);
                            }
                          : () {},
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
                              height: 250,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  height: 60,
                                  width: 100,
                                  child: ElevatedButton(
                                      onPressed: () async {
                                        notificationTimer?.cancel();
                                        await audioPlayer?.stop();
                                        Navigator.of(context).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        primary: Colors.green,
                                      ),
                                      child: Text(
                                        "戻る",
                                        style: TextStyle(fontSize: 20),
                                      )),
                                ),
                                SizedBox(
                                  height: 60,
                                  width: 100,
                                  child: ElevatedButton(
                                      onPressed: hiddenOkButton == false
                                          ? () {
                                              isAdjusting = false;
                                              isCounting = true;
                                            }
                                          : () {},
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        primary: hiddenOkButton == false
                                            ? Colors.green
                                            : Colors.green.withOpacity(0.3),
                                      ),
                                      child: Text(
                                        "OK",
                                        style: TextStyle(fontSize: 20),
                                      )),
                                ),
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
          if (k["part"] == "nose"
              // ||
              // k["part"] == "leftEye" ||
              // k["part"] == "rightEye" ||
              // k["part"] == "leftEar" ||
              // k["part"] == "rightEar"
              ) {
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
