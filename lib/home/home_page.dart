import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:posture_correction/camera/camera_page.dart';
import 'package:posture_correction/help/help_page.dart';
import 'package:posture_correction/home/home_model.dart';
import 'package:posture_correction/utils.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return ChangeNotifierProvider<HomeModel>(
        create: (_) => HomeModel()..loadModel(context),
        builder: (context, snapshot) {
          return Scaffold(
            body: Consumer<HomeModel>(builder: (context, model, child) {
              //全体の計測時間を時・分・秒に変換
              int hour = Utils.totalMeasurementTimeForAll ~/ 60 ~/ 60;
              int minute = Utils.totalMeasurementTimeForAll ~/ 60 % 60;
              int second = Utils.totalMeasurementTimeForAll % 60;
              //当月の計測時間を時・分・秒に変換
              int hour2 = Utils.totalMeasurementTimeForThisMonth ~/ 60 ~/ 60;
              int minute2 = Utils.totalMeasurementTimeForThisMonth ~/ 60 % 60;
              int second2 = Utils.totalMeasurementTimeForThisMonth % 60;
              //今日の計測時間を時・分・秒に変換
              int hour3 = Utils.totalMeasurementTimeForTheDay ~/ 60 ~/ 60;
              int minute3 = Utils.totalMeasurementTimeForTheDay ~/ 60 % 60;
              int second3 = Utils.totalMeasurementTimeForTheDay % 60;
              return Stack(children: [
                SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                  child: FadeInImage.memoryNetwork(
                    placeholder: kTransparentImage,
                    image:
                        "https://images.unsplash.com/photo-1499951360447-b19be8fe80f5?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTZ8fCVFNiU5QyVCQSUyMCVFMyU4MSU4QSVFMyU4MSU5NyVFMyU4MiU4MyVFMyU4MiU4Q3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60",
                    fit: BoxFit.cover,
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      //ヘルプページへ遷移するボタン
                      Container(
                        alignment: Alignment.bottomRight,
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
                                side: BorderSide(
                                  color: Colors.white, //色
                                  width: 1, //太さ
                                ),
                                shape: CircleBorder(),
                                primary: Colors.grey),
                          ),
                        ),
                      ),
                      //カメラページへの遷移ボタン
                      SizedBox(
                        height: 200,
                        width: 200,
                        child: ElevatedButton(
                          onPressed: () async {
                            final value = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CameraPage()));
                            notificationTimer?.cancel();
                            await audioPlayer?.stop();
                            await model.getAverageData();
                            //カメラページから戻った際に計測結果をダイアログで表示
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
                                                      color: Colors
                                                          .greenAccent.shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text("姿勢"),
                                                  Text(
                                                    "(不良)：${value[2] ~/ 60 ~/ 60}時間${value[2] ~/ 60 % 60}分${value[2] % 60}秒",
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xffff1a1a)),
                                                  ),
                                                ],
                                              ),
                                              Text("警告回数：${value[3]}回"),
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
                                                      alignment:
                                                          Alignment.center,
                                                      child: Container(
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
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "●",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 18,
                                                                  color: Colors
                                                                      .greenAccent
                                                                      .shade700,
                                                                ),
                                                              ),
                                                              Text(
                                                                "：${((value[1] / value[0]) * 100).toStringAsFixed(1)}％",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .greenAccent
                                                                      .shade700,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "●",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    color: Color(
                                                                        0xffff1a1a)),
                                                              ),
                                                              Text(
                                                                "：${((value[2] / value[0]) * 100).toStringAsFixed(1)}％",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15,
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "START",
                                style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.greenAccent.shade700,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Text(
                                "MEASUREMENT",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.greenAccent.shade700,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            onPrimary: Colors.greenAccent.shade700,
                            elevation: 0,
                            shape: CircleBorder(),
                            side: BorderSide(
                              width: 1,
                              color: Colors.greenAccent.shade700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      //総合・今月・今日の平均データを表示
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
                                  PieGraph(
                                      dataOfDate: "総合データ",
                                      numberOfMeasurements:
                                          Utils.numberOfAllMeasurements,
                                      hour: hour,
                                      minute: minute,
                                      second: second,
                                      rateOfGoodPosture:
                                          Utils.percentOfAllGoodPostureSec,
                                      showingRate: showingSections),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  //今月のデータ
                                  PieGraph(
                                      dataOfDate: "今月のデータ",
                                      numberOfMeasurements:
                                          Utils.numberOfMeasurementsThisMonth,
                                      hour: hour2,
                                      minute: minute2,
                                      second: second2,
                                      rateOfGoodPosture: Utils
                                          .percentOfThisMonthGoodPostureSec,
                                      showingRate: showingSections),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  //今日のデータ
                                  PieGraph(
                                      dataOfDate: "今日のデータ",
                                      numberOfMeasurements:
                                          Utils.numberOfMeasurementsToday,
                                      hour: hour3,
                                      minute: minute3,
                                      second: second3,
                                      rateOfGoodPosture:
                                          Utils.percentOfTodayGoodPostureSec,
                                      showingRate: showingSections),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]);
            }),
          );
        });
  }

  //計測を終えた後アラートダイアログに結果を円グラフで表示
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

//計測データを表示（円グラフを除く）
class PieGraph extends StatelessWidget {
  PieGraph(
      {required this.dataOfDate,
      required this.numberOfMeasurements,
      required this.hour,
      required this.minute,
      required this.second,
      required this.rateOfGoodPosture,
      required this.showingRate});

  final String dataOfDate;
  final int numberOfMeasurements;
  final int hour;
  final int minute;
  final int second;
  final double rateOfGoodPosture;
  final Function(double, int) showingRate;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 10,
            ),
            Container(
              height: 25,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text(
                    dataOfDate,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
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
                borderRadius: BorderRadius.circular(10),
              ),
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "計測回数：$numberOfMeasurements 回",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          // color: Color(0xff00c904),
                        ),
                      ),
                      Text(
                        "計測時間：$hour時間$minute分$second秒",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "姿勢　(良)：$rateOfGoodPosture%",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent.shade700,
                        ),
                      ),
                      Text(
                        "姿勢(不良)：${numberOfMeasurements > 0 ? (100 - rateOfGoodPosture).toStringAsFixed(1) : 0.0}%",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
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
                    borderData: FlBorderData(show: false),
                    startDegreeOffset: 270,
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections:
                        showingRate(rateOfGoodPosture, numberOfMeasurements),
                  ),
                ),
              ),
            ),
            Container(
              height: 120,
              width: 120,
              child: Center(
                child: Text(
                  "$rateOfGoodPosture%",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: rateOfGoodPosture > 0
                        ? Colors.greenAccent.shade700
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

//計測データを表示（円グラフ）
List<PieChartSectionData> showingSections(
    rateOfGoodPosture, numberOfMeasurements) {
  return List.generate(2, (i) {
    final radius = 10.0;
    switch (i) {
      case 0:
        return PieChartSectionData(
          color: Colors.greenAccent.shade700,
          value: rateOfGoodPosture,
          radius: radius,
          showTitle: false,
        );
      case 1:
        return PieChartSectionData(
          color:
              numberOfMeasurements < 1 ? Color(0xffd0d0d0) : Color(0xffff1a1a),
          value: 100.toDouble() - rateOfGoodPosture,
          showTitle: false,
          radius: radius,
        );
      default:
        throw Error();
    }
  });
}
