import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:posture_correction/utils.dart';
import 'package:provider/provider.dart';

import 'camera_model.dart';
import 'coordinates.dart';

final audioPlayer = AudioPlayer();
bool? _soundLoop;
bool? detection;
bool? isCounting;
bool? isAdjusting;
bool? _hiddenOkButton;
bool? dataExist;
bool? measuredOverOneSec;
Timer? notificationTimer;

class CameraPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _soundLoop = false;
    isAdjusting = true;
    isCounting = false;
    detection = false;
    _hiddenOkButton = false;
    dataExist = false;
    measuredOverOneSec = false;
    return ChangeNotifierProvider<CameraModel>(
        create: (_) => CameraModel()
          ..getCamera()
          ..autoSleepWakeUp(true),
        builder: (context, snapshot) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
              body: Consumer<CameraModel>(builder: (context, model, child) {
                //カメラの利用許可の有無で表示するページを変更
                if (model.controller == null) {
                  //カメラ・マイクのアクセスの案内ページ
                  return Center(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "カメラ・マイクへのアクセスが\n許可されていません。",
                            style: TextStyle(fontSize: 25),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "端末の設定からこのアプリ（Posture correction）の\nカメラ・マイクへのアクセスを許可してください。",
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
                                  backgroundColor: Colors.greenAccent.shade700,
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
                //カメラページ
                return Stack(
                  children: [
                    Container(
                      height: double.infinity,
                      width: double.infinity,
                      color: Colors.black,
                    ),
                    CustomPaint(
                      foregroundPainter: model.posePainter,
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio:
                                1 / model.controller!.value.aspectRatio,
                            child: Container(
                              color: Colors.black,
                              child: CameraPreview(model.controller!),
                            ),
                          ),
                          if (model.darkMode == true)
                            AspectRatio(
                              aspectRatio:
                                  1 / model.controller!.value.aspectRatio,
                              child: Container(
                                color: Colors.black,
                              ),
                            ),
                        ],
                      ),
                    ),
                    //計測終了ボタン
                    Align(
                      alignment: const Alignment(0, 0.9),
                      child: FloatingActionButton(
                        heroTag: "hero1",
                        //計測時間0秒を回避する
                        onPressed: model.measuringSec > 0
                            ? () async {
                                notificationTimer?.cancel();
                                audioPlayer.stop();
                                detection = false;
                                isCounting = false;
                                isAdjusting = true;
                                dataExist = true;
                                model.stopTimer();
                                model.stopBadPostureTimer();
                              }
                            : () {},
                        child: const Icon(Icons.stop),
                        backgroundColor: Colors.red,
                      ),
                    ),
                    //計測前の調整画面
                    if (!isCounting! && isAdjusting!)
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.grey.withOpacity(0.5),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment(0, -0.6),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  Text(
                                    dataExist!
                                        ? "計測時間：${model.measuringSec ~/ 60 ~/ 60}時間${model.measuringSec ~/ 60 % 60}分${model.measuringSec % 60}秒"
                                        : "姿勢を正し白点がグリーンラインの枠内に収まるように端末の位置・音量を調整してください",
                                    style: dataExist!
                                        ? TextStyle(
                                            fontSize: 25, color: Colors.white)
                                        : TextStyle(
                                            fontSize: 19, color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    dataExist!
                                        ? "（※再開ボタンは白点がグリーンラインの枠内に位置する時のみ押下できます）"
                                        : "（※開始ボタンは白点がグリーンラインの枠内に位置する時のみ押下できます）",
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment(0, 0.3),
                              child: Wrap(
                                direction: Axis.vertical,
                                children: [
                                  FittedBox(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        audioPlayer.play(AssetSource(
                                            "sounds/notification.mp3"));
                                      },
                                      label: Text("音量チェック"),
                                      icon: Icon(Icons.volume_up),
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "警告音設定秒数：${Utils.timeToNotification}秒",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment(0, 0.6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    height: 60,
                                    width: 100,
                                    child: ElevatedButton(
                                      onPressed: dataExist!
                                          ? () async {
                                              try {
                                                await model.addData();
                                              } catch (e) {
                                                await showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return CupertinoAlertDialog(
                                                        title: Text("エラー"),
                                                        content:
                                                            Text("保存に失敗しました"),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Text("OK"),
                                                          )
                                                        ],
                                                      );
                                                    });
                                              }

                                              notificationTimer?.cancel();
                                              audioPlayer.stop();
                                              model.autoSleepWakeUp(false);

                                              Navigator.of(context).pop([
                                                //計測時間
                                                model.measuringSec,
                                                //姿勢(良)の時間
                                                model.measuringSec -
                                                    model
                                                        .measuringBadPostureSec,
                                                //姿勢(不良)の時間
                                                model.measuringBadPostureSec,
                                                //猫背通知回数
                                                model.notificationCounter
                                                    .toString(),
                                              ]);
                                            }
                                          : () {
                                              notificationTimer?.cancel();
                                              audioPlayer.stop();
                                              model.autoSleepWakeUp(false);

                                              Navigator.of(context).pop();
                                            },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        backgroundColor: dataExist!
                                            ? Colors.red
                                            : Colors.greenAccent.shade700,
                                      ),
                                      child: Text(
                                        dataExist! ? "終了" : "戻る",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 60,
                                    width: 100,
                                    child: ElevatedButton(
                                      onPressed: _hiddenOkButton == false
                                          ? () {
                                              isAdjusting = false;
                                              isCounting = true;
                                              audioPlayer.stop();
                                            }
                                          : () {},
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        backgroundColor:
                                            _hiddenOkButton == false
                                                ? Colors.greenAccent.shade700
                                                : Colors.greenAccent.shade700
                                                    .withOpacity(0.3),
                                      ),
                                      child: Text(
                                        dataExist! ? "再開" : "開始",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    //ダークモード切り替えボタン
                    Align(
                      alignment: const Alignment(0, -0.8),
                      child: ElevatedButton(
                        onPressed: () {
                          model.getScreenMode();
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: model.darkMode == false
                                ? Colors.black
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            )),
                        child: model.darkMode == false
                            ? Text("ダークモード：OFF")
                            : Text(
                                "ダークモード：ON ",
                                style: TextStyle(color: Colors.black),
                              ),
                      ),
                    ),
                    //姿勢情報を取得できない場合に表示（離席中など）
                    if (isCounting! && !detection!)
                      Center(
                        child: Text(
                          "計測停止中",
                          style: TextStyle(fontSize: 30, color: Colors.white),
                        ),
                      ),
                  ],
                );
              }),
            ),
          );
        });
  }
}

//画面に緑線・赤線・白点を表示
class PosePainter extends CustomPainter {
  PosePainter(this.poses, this.imageSize, this.rotation,
      this.cameraLensDirection, this.cameraModel);

  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  final CameraModel cameraModel;
  bool beyond = false;

  @override
  void paint(Canvas canvas, Size size) {
    final aboveLineStart = Offset(0, size.height * Utils.greenLineRange);
    final aboveLineEnd = Offset(size.width, size.height * Utils.greenLineRange);
    final belowLineStart = Offset(0, size.height / 2);
    final belowLineEnd = Offset(size.width, size.height / 2);
    final paint = Paint()..color = Colors.white;

    if (poses.isNotEmpty) {
      if (isCounting! && !detection!) {
        detection = true;
        cameraModel.startTimer();
        print("Timer Start");
      }
      for (final pose in poses) {
        pose.landmarks.forEach((_, landmark) {
          if (landmark.type.toString() == "PoseLandmarkType.nose") {
            //noseの位置に白点を表示
            canvas.drawCircle(
                Offset(
                  translateX(
                    landmark.x,
                    size,
                    imageSize,
                    rotation,
                    cameraLensDirection,
                  ),
                  translateY(
                    landmark.y,
                    size,
                    imageSize,
                    rotation,
                    cameraLensDirection,
                  ),
                ),
                5,
                paint);
            //PoseLandmarkType.noseが下側の緑線以下にあるとき
            if (landmark.y > imageSize.height / 2) {
              paint.color = Colors.greenAccent;
              paint.strokeWidth = 3;
              canvas.drawLine(aboveLineStart, aboveLineEnd, paint);
              paint.color = Colors.red;
              paint.strokeWidth = 3;
              canvas.drawLine(belowLineStart, belowLineEnd, paint);
              beyond = true;
              notificationSound(beyond);
              //PoseLandmarkType.noseが上側の緑線以上にあるとき
            } else if (landmark.y < imageSize.height * Utils.greenLineRange) {
              paint.color = Colors.yellowAccent;
              paint.strokeWidth = 3;
              canvas.drawLine(aboveLineStart, aboveLineEnd, paint);
              paint.color = Colors.greenAccent;
              paint.strokeWidth = 3;
              canvas.drawLine(belowLineStart, belowLineEnd, paint);
              beyond = true;
              notificationSound2(beyond);
              //PoseLandmarkType.noseが2本の緑線の間にあるとき
            } else {
              paint.color = Colors.greenAccent;
              paint.strokeWidth = 3;
              canvas.drawLine(aboveLineStart, aboveLineEnd, paint);
              paint.color = Colors.greenAccent;
              paint.strokeWidth = 3;
              canvas.drawLine(belowLineStart, belowLineEnd, paint);
              notificationSound(beyond);
            }
          }
        });
      }
    } else if (detection! || isAdjusting!) {
      notificationTimer?.cancel();
      detection = false;
      _soundLoop = false;
      cameraModel.stopTimer();
      cameraModel.stopBadPostureTimer();
      print("Timer Stop");
      audioPlayer.stop();
    }
  }

  //時間経過で警告音を鳴らす（PoseLandmarkType.noseが下側の緑線より下にある時）
  notificationSound(bool beyond) {
    if (beyond && !_soundLoop!) {
      _soundLoop = true;
      _hiddenOkButton = true;
      if (isCounting!) {
        cameraModel.startBadPostureTimer();
      }
      print("${Utils.timeToNotification}秒後警告");

      notificationTimer =
          Timer(Duration(seconds: Utils.timeToNotification), () {
        audioPlayer.play(AssetSource("sounds/notification.mp3"));
        audioPlayer.setReleaseMode(ReleaseMode.loop);
        if (isCounting!) {
          cameraModel.counter();
        }
      });
    } else if (!beyond && _soundLoop!) {
      _soundLoop = false;
      _hiddenOkButton = false;
      cameraModel.stopBadPostureTimer();
      notificationTimer?.cancel();
      audioPlayer.stop();
    }
  }

  //時間経過で警告音を鳴らす（PoseLandmarkType.noseが上側の緑線より上にある時）
  notificationSound2(bool beyond) {
    if (beyond && !_soundLoop!) {
      _soundLoop = true;
      _hiddenOkButton = true;

      notificationTimer =
          Timer(Duration(seconds: Utils.timeToNotification), () {
        audioPlayer.play(AssetSource("sounds/notification.mp3"));
        audioPlayer.setReleaseMode(ReleaseMode.loop);
      });
    } else if (!beyond && _soundLoop!) {
      _soundLoop = false;
      _hiddenOkButton = false;
      notificationTimer?.cancel();
      audioPlayer.stop();
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.poses != poses;
  }
}
