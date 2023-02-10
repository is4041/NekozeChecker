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
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          // height: screenSize.height * 0.75,
                          height: 650,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.lightGreenAccent,
                                // Colors.green,
                                Color(0xff009904),
                                // Color(0xff00c904),
                              ],
                            ),
                          ),
                        ),
                        // Align(
                        //   alignment: Alignment.bottomLeft,
                        //   child: ElevatedButton(
                        //     onPressed: () {
                        //       Navigator.push(
                        //           context,
                        //           MaterialPageRoute(
                        //               builder: (context) => HelpPage()));
                        //     },
                        //     child: Text(
                        //       "?",
                        //       style:
                        //           TextStyle(fontSize: 25, color: Colors.white),
                        //     ),
                        //     style: ElevatedButton.styleFrom(
                        //         shape: CircleBorder(), primary: Colors.green),
                        //   ),
                        // ),
                        // Align(
                        //   alignment: Alignment(1, 0),
                        //   child: ElevatedButton(
                        //     onPressed: () {
                        //       Navigator.push(
                        //           context,
                        //           MaterialPageRoute(
                        //               builder: (context) => HomePage()));
                        //     },
                        //     child: Text("?"),
                        //     style: ElevatedButton.styleFrom(
                        //         shape: CircleBorder(), primary: Colors.green),
                        //   ),
                        // ),
                        Column(
                          children: [
                            Container(
                              height: screenSize.height * 0.1,
                            ),
                            //全体平均の円グラフ
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  // height: screenSize.height * 0.25,
                                  height: 225,
                                  child: Center(
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: PieChart(
                                        PieChartData(
                                          borderData: FlBorderData(show: false),
                                          startDegreeOffset: 270,
                                          sectionsSpace: 0,
                                          centerSpaceRadius: 60,
                                          sections: showingSections1(model),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  // color: Colors.grey.withOpacity(0.5),
                                  // height: screenSize.height * 0.25,
                                  height: 225,
                                  child: Center(
                                    child: Text(
                                      "${Utils.percentOfAllGoodPostureSec}%",
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff00c904),
                                        // color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "全体平均",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Text(
                              "計測回数：${Utils.averageOfAllLength} 回",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            //今日と今月の平均の円グラフ
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          // height: screenSize.height * 0.15,
                                          height: 120,
                                          child: Center(
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
                                        ),
                                        Container(
                                          // color: Colors.grey.withOpacity(0.5),
                                          // height: screenSize.height * 0.15,
                                          height: 120,
                                          // width: screenSize.height * 0.15,
                                          width: 120,
                                          child: Center(
                                            child: Text(
                                              "${Utils.percentOfTodayGoodPostureSec}%",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff00c904),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "今日の平均",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    Text(
                                      "計測回数：${Utils.averageOfTodayLength} 回",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          // height: screenSize.height * 0.15,
                                          height: 120,
                                          child: Center(
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
                                        ),
                                        Container(
                                          // color: Colors.grey.withOpacity(0.5),
                                          // height: screenSize.height * 0.15,
                                          height: 120,
                                          // width: screenSize.height * 0.15,
                                          width: 120,
                                          child: Center(
                                            child: Text(
                                              "${Utils.percentOfThisMonthGoodPostureSec}%",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff00c904),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "今月の平均",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    Text(
                                      "計測回数：${Utils.averageOfThisMonthLength} 回",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      child: Container(
                        height: 50,
                        width: double.infinity,
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
                                    //todo　〜〜〜 内容要変更　〜〜〜
                                    return AlertDialog(
                                      title: Text("計測結果"),
                                      content: Container(
                                        height: 300,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text("計測時間：${value[0]}秒"),
                                            Row(
                                              // mainAxisAlignment:
                                              //     MainAxisAlignment.center,
                                              children: [
                                                Text("計測時間：姿勢"),
                                                Text(
                                                  "(良)：${value[1]}秒",
                                                  style: TextStyle(
                                                      color: Colors.green),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text("計測時間：姿勢"),
                                                Text(
                                                  "(不良)：${value[2]}秒",
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ],
                                            ),
                                            Text("猫背通知回数：${value[3]}回"),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Close"))
                                      ],
                                    );
                                    //todo　〜〜〜 内容要変更　〜〜〜
                                  });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              )),
                          child: Text(
                            "計測する",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            // style: TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HelpPage()));
                      },
                      child: Text(
                        "?",
                        style: TextStyle(fontSize: 25, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                          shape: CircleBorder(), primary: Colors.green),
                    ),
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     Text("今日の平均データ",
                    //         style: TextStyle(
                    //           fontSize: 20.0,
                    //         )),
                    //     Container(
                    //         height: 60,
                    //         width: double.infinity,
                    //         decoration: BoxDecoration(
                    //             border: Border.all(color: Colors.black12)),
                    //         child: Utils.dailyAverage != null
                    //             ? Text(
                    //                 Utils.dailyAverage != ""
                    //                     ? "平均約${Utils.dailyAverage}分に1回猫背になっています"
                    //                     : "-----",
                    //                 style: TextStyle(
                    //                   fontSize: 20.0,
                    //                 ),
                    //               )
                    //             : Text(
                    //                 "Loading...",
                    //                 style: TextStyle(fontSize: 20.0),
                    //               )),
                    //     Text(
                    //       "全体の平均データ",
                    //       style: TextStyle(
                    //         fontSize: 20.0,
                    //       ),
                    //     ),
                    //     Container(
                    //       height: 60,
                    //       width: double.infinity,
                    //       decoration: BoxDecoration(
                    //           border: Border.all(color: Colors.black12)),
                    //       child: Utils.totalAverage != null
                    //           ? Text(
                    //               Utils.totalAverage != ""
                    //                   ? "平均約${Utils.totalAverage}分に1回猫背になっています"
                    //                   : "-----",
                    //               style: TextStyle(
                    //                 fontSize: 20.0,
                    //               ),
                    //             )
                    //           : Text(
                    //               "Loading...",
                    //               style: TextStyle(fontSize: 20.0),
                    //             ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              );
            }),
          );
        });
  }

//全体平均の円グラフ
  List<PieChartSectionData> showingSections1(model) {
    return List.generate(2, (i) {
      final radius = 25.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Color(0xff00cb00),
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

//今日の平均の円グラフ
  List<PieChartSectionData> showingSections2() {
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
                    Utils.averageOfTodayLength > 0
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

//今月の平均の円グラフ
  List<PieChartSectionData> showingSections3() {
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
}
