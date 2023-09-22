import 'package:audioplayers/audioplayers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:posture_correction/camera/camera_page.dart';
import 'package:posture_correction/help/help_page.dart';
import 'package:posture_correction/home/home_model.dart';
import 'package:posture_correction/utils.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:volume_watcher/volume_watcher.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return ChangeNotifierProvider<HomeModel>(
        create: (_) => HomeModel()..getData(context),
        builder: (context, snapshot) {
          return Scaffold(
            body: Consumer<HomeModel>(builder: (context, model, child) {
              //全体の計測時間を時・分・秒に変換
              int _hour = Utils.totalMeasurementTimeForAll ~/ 60 ~/ 60;
              int _minute = Utils.totalMeasurementTimeForAll ~/ 60 % 60;
              int _second = Utils.totalMeasurementTimeForAll % 60;
              //当月の計測時間を時・分・秒に変換
              int _hour2 = Utils.totalMeasurementTimeForThisMonth ~/ 60 ~/ 60;
              int _minute2 = Utils.totalMeasurementTimeForThisMonth ~/ 60 % 60;
              int _second2 = Utils.totalMeasurementTimeForThisMonth % 60;
              //今日の計測時間を時・分・秒に変換
              int _hour3 = Utils.totalMeasurementTimeForTheDay ~/ 60 ~/ 60;
              int _minute3 = Utils.totalMeasurementTimeForTheDay ~/ 60 % 60;
              int _second3 = Utils.totalMeasurementTimeForTheDay % 60;
              return Stack(children: [
                SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                  child: FadeInImage.memoryNetwork(
                    placeholder: kTransparentImage,
                    image:
                        "https://images.unsplash.com/photo-1665491573094-72fec461b4de?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2940&q=80",
                    // "https://images.unsplash.com/photo-1547960450-2ea08b931270?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2832&q=80",
                    // "https://images.unsplash.com/photo-1499951360447-b19be8fe80f5?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTZ8fCVFNiU5QyVCQSUyMCVFMyU4MSU4QSVFMyU4MSU5NyVFMyU4MiU4MyVFMyU4MiU4Q3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60",
                    fit: BoxFit.cover,
                  ),
                ),
                SingleChildScrollView(
                  child: Column(children: [
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
                          child: Text(
                            "?",
                            style: TextStyle(fontSize: 30),
                          ),
                          style: ElevatedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.lightGreenAccent, //色
                                width: 2, //太さ
                              ),
                              shape: CircleBorder(),
                              backgroundColor: Colors.greenAccent.shade700),
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
                          model.audioStop();
                          //カメラページから戻った際に計測結果をダイアログで表示
                          if (value != null) {
                            model.getAverageData();
                            await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    insetPadding: EdgeInsets.all(10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "計測評価は...",
                                          style: TextStyle(fontSize: 22),
                                        ),
                                        Text(
                                          "${((value[1] / value[0]) * 100).toStringAsFixed(1)}",
                                          style: TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  Colors.greenAccent.shade700),
                                        ),
                                        Text(
                                          "点",
                                          style: TextStyle(fontSize: 22),
                                        ),
                                        if (Utils.nekoMode)
                                          Text(
                                            "ニャ",
                                            style: TextStyle(fontSize: 22),
                                          ),
                                        Text(
                                          "!!!",
                                          style: TextStyle(fontSize: 22),
                                        ),
                                      ],
                                    ),
                                    content: Container(
                                      height: 300,
                                      width: 300,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.greenAccent.shade700,
                                          width: 3,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "計測時間",
                                                    style:
                                                        TextStyle(fontSize: 20),
                                                  ),
                                                  Text(
                                                    "${value[0] ~/ 60 ~/ 60}時間${value[0] ~/ 60 % 60}分${value[0] % 60}秒",
                                                    style:
                                                        TextStyle(fontSize: 20),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "姿勢(良)",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors
                                                            .greenAccent
                                                            .shade700),
                                                  ),
                                                  Text(
                                                    "${value[1] ~/ 60 ~/ 60}時間${value[1] ~/ 60 % 60}分${value[1] % 60}秒",
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors
                                                          .greenAccent.shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "姿勢(猫背)",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.red),
                                                  ),
                                                  Text(
                                                    "${value[2] ~/ 60 ~/ 60}時間${value[2] ~/ 60 % 60}分${value[2] % 60}秒",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color:
                                                            Color(0xffff1a1a)),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "警告回数",
                                                    style:
                                                        TextStyle(fontSize: 20),
                                                  ),
                                                  Text(
                                                    "${value[3]}回",
                                                    style:
                                                        TextStyle(fontSize: 20),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Row(
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
                                                                  _showingSectionsOnDialog(
                                                                      value),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Container(
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
                                                                  fontSize: 23,
                                                                  color: Colors
                                                                      .greenAccent
                                                                      .shade700,
                                                                ),
                                                              ),
                                                              Text(
                                                                "：${((value[1] / value[0]) * 100).toStringAsFixed(1)}％",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 20,
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
                                                                        23,
                                                                    color: Color(
                                                                        0xffff1a1a)),
                                                              ),
                                                              Text(
                                                                "：${((value[2] / value[0]) * 100).toStringAsFixed(1)}％",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        20,
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
                                    ),
                                    actions: [
                                      Center(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 30.0),
                                            child: Text(
                                              "OK",
                                              style: TextStyle(
                                                  fontSize: 25,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            backgroundColor:
                                                Colors.greenAccent.shade700,
                                          ),
                                        ),
                                      )
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
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (Utils.nekoMode)
                              Text(
                                "ニャ！",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent.shade700,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: CircleBorder(),
                          side: BorderSide(
                            width: 10,
                            color: Colors.lightGreenAccent,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    _PieGraph(
                      dataOfDate: "今日のデータ",
                      numberOfMeasurements: Utils.numberOfMeasurementsToday,
                      hour: _hour3,
                      minute: _minute3,
                      second: _second3,
                      rateOfGoodPosture: Utils.percentOfTodayGoodPostureSec,
                      showingRate: _showingSections,
                      beginColor: Colors.lightGreenAccent,
                      endColor: Color(0xff29fa2f),
                    ),
                    _PieGraph(
                      dataOfDate: "今月のデータ",
                      numberOfMeasurements: Utils.numberOfMeasurementsThisMonth,
                      hour: _hour2,
                      minute: _minute2,
                      second: _second2,
                      rateOfGoodPosture: Utils.percentOfThisMonthGoodPostureSec,
                      showingRate: _showingSections,
                      beginColor: Color(0xff29fa2f),
                      endColor: Color(0xff0ecd12),
                    ),
                    _PieGraph(
                      dataOfDate: "総合データ",
                      numberOfMeasurements: Utils.numberOfAllMeasurements,
                      hour: _hour,
                      minute: _minute,
                      second: _second,
                      rateOfGoodPosture: Utils.percentOfAllGoodPostureSec,
                      showingRate: _showingSections,
                      beginColor: Color(0xff0ecd12),
                      endColor: Color(0xff01ad04),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ]),
                ),
              ]);
            }),
          );
        });
  }
}

//計測を終えた後アラートダイアログに結果を円グラフで表示
List<PieChartSectionData> _showingSectionsOnDialog(value) {
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

//計測データを表示（円グラフ）
List<PieChartSectionData> _showingSections(
    double rateOfGoodPosture, int numberOfMeasurements) {
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

//計測データを表示（計測回数・計測時間・姿勢(良・不良)率）
class _PieGraph extends StatelessWidget {
  _PieGraph(
      {required this.dataOfDate,
      required this.numberOfMeasurements,
      required this.hour,
      required this.minute,
      required this.second,
      required this.rateOfGoodPosture,
      required this.showingRate,
      required this.beginColor,
      required this.endColor});

  final String dataOfDate;
  final int numberOfMeasurements;
  final int hour;
  final int minute;
  final int second;
  final double rateOfGoodPosture;
  final Function(double, int) showingRate;
  final Color beginColor;
  final Color endColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, bottom: 10, left: 10),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              beginColor.withOpacity(0.9),
              endColor.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
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
                              "計測回数   ：$numberOfMeasurements 回",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                // color: Color(0xff00c904),
                              ),
                            ),
                            Text(
                              "計測時間   ：$hour時間$minute分$second秒",
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
                              "姿勢(猫背)：${numberOfMeasurements > 0 ? (100 - rateOfGoodPosture).toStringAsFixed(1) : 0.0}%",
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
                          sections: showingRate(
                              rateOfGoodPosture, numberOfMeasurements),
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
          ),
        ),
      ),
    );
  }
}
