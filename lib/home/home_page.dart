import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:posture_correction/camera/camera_page.dart';
import 'package:posture_correction/help/help_page.dart';
import 'package:posture_correction/home/home_model.dart';
import 'package:posture_correction/utils.dart';
import 'package:provider/provider.dart';

import '../data.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return ChangeNotifierProvider<HomeModel>(
        create: (_) => HomeModel()
          ..loadModel()
          ..getProviderId()
          ..getUserId()
          ..getTimeToNotification()
          ..getAverage(),
        builder: (context, snapshot) {
          return Scaffold(
            body: Consumer<HomeModel>(builder: (context, model, child) {
              int hour = Utils.overallMeasuringTime ~/ 60 ~/ 60;
              int minute = Utils.overallMeasuringTime ~/ 60 % 60;
              int second = Utils.overallMeasuringTime % 60;
              int hour2 = Utils.thisMonthMeasuringTime ~/ 60 ~/ 60;
              int minute2 = Utils.thisMonthMeasuringTime ~/ 60 % 60;
              int second2 = Utils.thisMonthMeasuringTime % 60;
              int hour3 = Utils.todayMeasuringTime ~/ 60 ~/ 60;
              int minute3 = Utils.todayMeasuringTime ~/ 60 % 60;
              int second3 = Utils.todayMeasuringTime % 60;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.bottomRight,
                      // color: Colors.green,
                      height: screenSize.height * 0.1,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HelpPage()));
                          },
                          child: Text("?"),
                          style: ElevatedButton.styleFrom(
                              shape: CircleBorder(), primary: Colors.grey),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () async {
                          final value = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CameraPage()));
                          model.getAverage();
                          if (value != null) {
                            await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("計測結果"),
                                    content: Container(
                                      height: 240,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                "計測時間：${value[0] ~/ 60 ~/ 60}時間${value[0] ~/ 60 % 60}分${value[0] % 60}秒"),
                                            Row(
                                              children: [
                                                Text("姿勢"),
                                                Text(
                                                  "(良)：${value[1] ~/ 60 ~/ 60}時間${value[1] ~/ 60 % 60}分${value[1] % 60}秒",
                                                  style: TextStyle(
                                                      color: Color(0xff00c904)),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text("姿勢"),
                                                Text(
                                                  "(不良)：${value[2] ~/ 60 ~/ 60}時間${value[2] ~/ 60 % 60}分${value[2] % 60}秒",
                                                  style: TextStyle(
                                                      color: Color(0xffff1a1a)),
                                                ),
                                              ],
                                            ),
                                            Text("猫背通知回数：${value[3]}回"),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Align(
                                                    alignment: Alignment.center,
                                                    child: Container(
                                                      // color: Colors.grey
                                                      //     .withOpacity(0.2),
                                                      height: 120,
                                                      child: AspectRatio(
                                                        aspectRatio: 1,
                                                        child: PieChart(
                                                          PieChartData(
                                                            borderData:
                                                                FlBorderData(
                                                                    show:
                                                                        false),
                                                            startDegreeOffset:
                                                                270,
                                                            sectionsSpace: 0,
                                                            centerSpaceRadius:
                                                                40,
                                                            sections:
                                                                showingSections4(
                                                                    value),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: SizedBox(
                                                    height: 120,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              "●",
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  color: Color(
                                                                      0xff00c904)),
                                                            ),
                                                            Text(
                                                              "：${((value[1] / value[0]) * 100).toStringAsFixed(1)}％",
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: Color(
                                                                      0xff00c904)),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              "●",
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  color: Color(
                                                                      0xffff1a1a)),
                                                            ),
                                                            Text(
                                                              "：${((value[2] / value[0]) * 100).toStringAsFixed(1)}％",
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: Color(
                                                                      0xffff1a1a)),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ]),
                                    ),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("閉じる"))
                                    ],
                                  );
                                });
                          }
                        },
                        child: Text(
                          "start",
                          style:
                              TextStyle(fontSize: 40, color: Color(0xff00c904)),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          onPrimary: Colors.green,
                          elevation: 0,
                          shape: CircleBorder(),
                          side: BorderSide(width: 5, color: Color(0xff00c904)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Stack(
                        children: [
                          Container(
                            height: 400,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.lightGreenAccent,
                                  Color(0xff009904),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                //総合データ
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Container(
                                          height: 25,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: FittedBox(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              child: Text(
                                                "総合データ",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  // color: Colors.green
                                                  // color: Color(0xff00c904),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                          height: 70,
                                          width: 200,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: FittedBox(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "計測回数：${Utils.numberOfOverallMeasurements} 回",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      // color: Color(0xff00c904),
                                                    ),
                                                  ),
                                                  Text(
                                                    "計測時間：$hour時間$minute分$second秒",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      // color: Color(0xff00c904),
                                                    ),
                                                  ),
                                                  Text(
                                                    "姿勢　(良)：${Utils.percentOfAllGoodPostureSec}%",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xff00c904)),
                                                  ),
                                                  Text(
                                                    "姿勢(不良)：${Utils.percentOfAllGoodPostureSec > 0 ? (100 - Utils.percentOfAllGoodPostureSec).toStringAsFixed(1) : 0.0}%",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xffff1a1a),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Stack(
                                      children: [
                                        Container(
                                          height: 120,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: AspectRatio(
                                            aspectRatio: 1,
                                            child: PieChart(
                                              PieChartData(
                                                borderData:
                                                    FlBorderData(show: false),
                                                startDegreeOffset: 270,
                                                sectionsSpace: 0,
                                                centerSpaceRadius: 40,
                                                sections: showingSections1(),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 120,
                                          width: 120,
                                          child: Center(
                                            child: Text(
                                              "${Utils.percentOfAllGoodPostureSec}%",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    Utils.percentOfAllGoodPostureSec >
                                                            0
                                                        ? Color(0xff00c904)
                                                        : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                //今月のデータ
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Container(
                                          height: 25,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: FittedBox(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              child: Text(
                                                "今月のデータ",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  // color: Color(0xff00c904),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                          height: 70,
                                          width: 200,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: FittedBox(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "計測回数：${Utils.numberOfMeasurementsThisMonth} 回",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      // color: Color(0xff00c904),
                                                    ),
                                                  ),
                                                  Text(
                                                    "計測時間：$hour2時間$minute2分$second2秒",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      // color: Color(0xff00c904),
                                                    ),
                                                  ),
                                                  Text(
                                                    "姿勢　(良)：${Utils.percentOfThisMonthGoodPostureSec}%",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xff00c904)),
                                                  ),
                                                  Text(
                                                    "姿勢(不良)：${Utils.percentOfThisMonthGoodPostureSec > 0 ? (100 - Utils.percentOfThisMonthGoodPostureSec).toStringAsFixed(1) : 0.0}%",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xffff1a1a),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Stack(
                                      children: [
                                        Container(
                                          height: 120,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: AspectRatio(
                                            aspectRatio: 1,
                                            child: PieChart(
                                              PieChartData(
                                                borderData:
                                                    FlBorderData(show: false),
                                                startDegreeOffset: 270,
                                                sectionsSpace: 0,
                                                centerSpaceRadius: 40,
                                                sections: showingSections2(),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 120,
                                          width: 120,
                                          child: Center(
                                            child: Text(
                                              "${Utils.percentOfThisMonthGoodPostureSec}%",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    Utils.percentOfThisMonthGoodPostureSec >
                                                            0
                                                        ? Color(0xff00c904)
                                                        : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                //今日のデータ
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Container(
                                          height: 25,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: FittedBox(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              child: Text(
                                                "今日のデータ",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  // color: Color(0xff00c904),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                          height: 70,
                                          width: 200,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: FittedBox(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "計測回数：${Utils.numberOfMeasurementsToday} 回",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      // color: Color(0xff00c904),
                                                    ),
                                                  ),
                                                  Text(
                                                    "計測時間：$hour3時間$minute3分$second3秒",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      // color: Color(0xff00c904),
                                                    ),
                                                  ),
                                                  Text(
                                                    "姿勢　(良)：${Utils.percentOfTodayGoodPostureSec}%",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xff00c904)),
                                                  ),
                                                  Text(
                                                    "姿勢(不良)：${Utils.percentOfTodayGoodPostureSec > 0 ? (100 - Utils.percentOfTodayGoodPostureSec).toStringAsFixed(1) : 0.0}%",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xffff1a1a),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Stack(
                                      children: [
                                        Container(
                                          height: 120,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: AspectRatio(
                                            aspectRatio: 1,
                                            child: PieChart(
                                              PieChartData(
                                                borderData:
                                                    FlBorderData(show: false),
                                                startDegreeOffset: 270,
                                                sectionsSpace: 0,
                                                centerSpaceRadius: 40,
                                                sections: showingSections3(),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 120,
                                          width: 120,
                                          child: Center(
                                            child: Text(
                                              "${Utils.percentOfTodayGoodPostureSec}%",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    Utils.percentOfTodayGoodPostureSec >
                                                            0
                                                        ? Color(0xff00c904)
                                                        : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        });
  }

//全体平均の円グラフ
  List<PieChartSectionData> showingSections1() {
    return List.generate(2, (i) {
      final radius = 10.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Color(0xff00c904),
            value: Utils.percentOfAllGoodPostureSec,
            radius: radius,
            showTitle: false,
          );
        case 1:
          return PieChartSectionData(
            color: Utils.percentOfAllGoodPostureSec == 0
                ? Color(0xffd0d0d0)
                : Color(0xffff1a1a),
            value: 100 - Utils.percentOfAllGoodPostureSec,
            showTitle: false,
            radius: radius,
          );
        default:
          throw Error();
      }
    });
  }

//今月の平均の円グラフ
  List<PieChartSectionData> showingSections2() {
    return List.generate(2, (i) {
      final radius = 10.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Color(0xff00c904),
            value: Utils.percentOfThisMonthGoodPostureSec,
            radius: radius,
            showTitle: false,
          );
        case 1:
          return PieChartSectionData(
            color: Utils.percentOfThisMonthGoodPostureSec == 0
                ? Color(0xffd0d0d0)
                : Color(0xffff1a1a),
            value: 100 - Utils.percentOfThisMonthGoodPostureSec,
            showTitle: false,
            radius: radius,
          );
        default:
          throw Error();
      }
    });
  }

  //今日の平均の円グラフ
  List<PieChartSectionData> showingSections3() {
    return List.generate(2, (i) {
      final radius = 10.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Color(0xff00c904),
            value: Utils.percentOfTodayGoodPostureSec,
            radius: radius,
            showTitle: false,
          );
        case 1:
          return PieChartSectionData(
            color: Utils.percentOfTodayGoodPostureSec != 0 &&
                    Utils.numberOfMeasurementsToday > 0
                ? Color(0xffff1a1a)
                : Color(0xffd0d0d0),
            value: 100 - Utils.percentOfTodayGoodPostureSec,
            showTitle: false,
            radius: radius,
          );
        default:
          throw Error();
      }
    });
  }

  //アラートダイアログに表示
  List<PieChartSectionData> showingSections4(value) {
    return List.generate(2, (i) {
      final radius = 15.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Color(0xff00c904),
            value: value[1].toDouble(),
            radius: radius,
            showTitle: false,
          );
        case 1:
          return PieChartSectionData(
            color: Color(0xffff1a1a),
            value: value[2].toDouble(),
            showTitle: false,
            radius: radius,
          );
        default:
          throw Error();
      }
    });
  }
}
