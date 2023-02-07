import 'package:fl_chart/fl_chart.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:posture_correction/graph/graph_model.dart';
import 'package:provider/provider.dart';

import 'dart:math';
import '../data.dart';

class GraphPage extends StatelessWidget {
  List<Color> gradientColors = [
    Color(0xff9aee9b),
    // Color(0xFF2BD600),
    Color(0xff4caf50),
  ];

  List<Color> gradientColors2 = [
    Color(0xfff3adad),
    Color(0xffff3838),
  ];

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return ChangeNotifierProvider<GraphModel>(
        create: (_) => GraphModel()..fetchGraphData(),
        builder: (context, snapshot) {
          return Consumer<GraphModel>(builder: (context, model, child) {
            return Stack(
              children: [
                Scaffold(
                  appBar: AppBar(
                    elevation: 0,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {
                            model.getLastMonthData();
                          },
                          icon: Icon(Icons.arrow_back_ios_outlined),
                          color: Colors.black,
                        ),
                        Center(
                          child: Text(
                            model.year! + " / " + model.month!,
                            style: TextStyle(
                              fontSize: 25.0,
                              color: Colors.greenAccent.shade700,
                              // fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        Transform.rotate(
                          angle: 180 * pi / 180,
                          child: IconButton(
                            onPressed: monthCounter < 0
                                ? () {
                                    model.getNextMonthData();
                                  }
                                : () {},
                            icon: Icon(Icons.arrow_back_ios_outlined),
                            color:
                                monthCounter < 0 ? Colors.black : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.grey[50],
                  ),
                  body: Column(
                    children: [
                      Container(
                        height: 10,
                      ),
                      Stack(
                        children: [
                          Stack(
                            children: [
                              //グラフのy軸部分のみ
                              Container(
                                height: screenSize.height * 0.5,
                                width: model.extendWidth &&
                                        model.num * 50 > screenSize.width
                                    ? model.num * 50
                                    : screenSize.width,
                                // color: Colors.green[200],
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 25.0),
                                  child: Container(
                                    margin: model.extendWidth
                                        ? null
                                        : EdgeInsets.only(right: 45),
                                    child: LineChart(
                                      yAxisData(model),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 20,
                                width: 45,
                                child: Center(
                                  child: Text(
                                    "(時間)",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          //グラフ全体
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              height: screenSize.height * 0.5,
                              width: model.extendWidth &&
                                      model.num * 50 > screenSize.width
                                  ? model.num * 50
                                  : screenSize.width,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 25.0),
                                child: LineChart(
                                  mainData(model),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              height: 30,
                              width: 250,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.greenAccent.shade700,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        model.rateOfGoodPosture != 0
                                            ? "：${model.rateOfGoodPosture}％"
                                            : "：0％",
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.greenAccent.shade700),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        100 - model.rateOfGoodPosture != 100
                                            ? "：${(100 - model.rateOfGoodPosture).toStringAsFixed(1)}％"
                                            : "：0％",
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: SizedBox(
                              height: 30,
                              child: ElevatedButton(
                                onPressed: () {
                                  model.changes();
                                },
                                child: Transform.rotate(
                                    angle: model.switchWidthIcon
                                        ? 0
                                        : 180 * pi / 180,
                                    child: Icon(Icons.arrow_back_ios_outlined)),
                                style: ElevatedButton.styleFrom(
                                    shape: CircleBorder(),
                                    primary: Colors.green),
                              ),
                            ),
                          ),

                          // if (model.num < 2)
                          // Center(
                          //   child: Container(
                          //     height: screenSize.height * 0.5,
                          //     child: Center(
                          //       child: Text(
                          //         "NO DATA",
                          //         style:
                          //             TextStyle(fontSize: 40, color: Colors.grey),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.topRight,
                        height: 20,
                        child: Text(
                          "(回)",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                      //日付　計測時間　姿勢(良)　姿勢(不)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border(
                            // top: BorderSide(color: Colors.grey),
                            bottom: BorderSide(color: Colors.grey),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: Text(
                                  "計測日",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "計測時間",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "姿勢",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    "(良)",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.greenAccent.shade700),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "姿勢",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    "(不良)",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      //履歴
                      Expanded(
                        child: Scrollbar(
                          child: ListView.builder(
                            itemCount: model.data.length,
                            itemBuilder: (context, index) {
                              //計測時間を時・分・秒に変換
                              num hour =
                                  model.data[index]["measuringSec"] ~/ 60 ~/ 60;
                              num minute =
                                  model.data[index]["measuringSec"] ~/ 60 % 60;
                              num second =
                                  model.data[index]["measuringSec"] % 60;
                              //姿勢（良）を時・分・秒に変換
                              num goodHour = model.data[index]
                                      ["measuringGoodPostureSec"] ~/
                                  60 ~/
                                  60;
                              num goodMinute = model.data[index]
                                      ["measuringGoodPostureSec"] ~/
                                  60 %
                                  60;
                              num goodSecond = model.data[index]
                                      ["measuringGoodPostureSec"] %
                                  60;
                              //姿勢（不良）を時・分・秒に変換
                              num badHour = model.data[index]
                                      ["measuringBadPostureSec"] ~/
                                  60 ~/
                                  60;
                              num badMinute = model.data[index]
                                      ["measuringBadPostureSec"] ~/
                                  60 %
                                  60;
                              num badSecond = model.data[index]
                                      ["measuringBadPostureSec"] %
                                  60;

                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.black12),
                                  ),
                                ),
                                child: ListTile(
                                  title: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "${index + 1}",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  "回目",
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              model.data[index]["createdAt"]
                                                      .substring(5, 7) +
                                                  "/" +
                                                  model.data[index]["createdAt"]
                                                      .substring(8, 10),
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.end,
                                          alignment: WrapAlignment.end,
                                          children: [
                                            Text(
                                              hour > 0 ? "$hour" : "",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              hour > 0 ? "時間" : "",
                                              style: TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              minute > 0 ? "$minute" : "",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              minute > 0 ? "分" : "",
                                              style: TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              second > 0 ? "$second" : "",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              second > 0 ? "秒" : "",
                                              style: TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.end,
                                          alignment: WrapAlignment.end,
                                          children: [
                                            Text(
                                              goodHour > 0 ? "$goodHour" : "",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors
                                                      .greenAccent.shade700),
                                            ),
                                            Text(
                                              goodHour > 0 ? "時間" : "",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors
                                                      .greenAccent.shade700),
                                            ),
                                            Text(
                                              goodMinute > 0
                                                  ? "$goodMinute"
                                                  : "",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors
                                                      .greenAccent.shade700),
                                            ),
                                            Text(
                                              goodMinute > 0 ? "分" : "",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors
                                                      .greenAccent.shade700),
                                            ),
                                            Text(
                                              goodSecond > 0
                                                  ? "$goodSecond"
                                                  : "",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors
                                                      .greenAccent.shade700),
                                            ),
                                            Text(
                                              goodSecond > 0 ? "秒" : "",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors
                                                      .greenAccent.shade700),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.end,
                                          alignment: WrapAlignment.end,
                                          children: [
                                            Text(
                                              badHour > 0 ? "$badHour" : "",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.red),
                                            ),
                                            Text(
                                              badHour > 0 ? "時間" : "",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.red),
                                            ),
                                            Text(
                                              badMinute > 0 ? "$badMinute" : "",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.red),
                                            ),
                                            Text(
                                              badMinute > 0 ? "分" : "",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.red),
                                            ),
                                            Text(
                                              badSecond > 0 ? "$badSecond" : "",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.red),
                                            ),
                                            Text(
                                              badSecond > 0 ? "秒" : "",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.red),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (model.isLoading)
                  Container(
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          });
        });
  }

  //数値非表示のためのウィジェット
  Widget hiddenTitleWidgets(double value, TitleMeta meta) {
    Widget text;
    switch (value.toInt()) {
      default:
        text = const Text(
          '',
        );
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  //x軸の値が8以下の時に適用
  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black,
      fontSize: 14,
    );
    String text;
    switch (value.toInt()) {
      case 1:
        text = '1';
        break;
      case 2:
        text = '2';
        break;
      case 3:
        text = '3';
        break;
      case 4:
        text = '4';
        break;
      case 5:
        text = '5';
        break;
      case 6:
        text = '6';
        break;
      case 7:
        text = '7';
        break;
      case 8:
        text = '8';
        break;
      default:
        return Container();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }

  //グラフのy軸の値
  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      // case 30:
      //   text = '0.5';
      //   break;
      case 60:
        text = '1';
        break;
      // case 90:
      //   text = '1.5';
      //   break;
      case 120:
        text = '2';
        break;
      // case 150:
      //   text = '2.5';
      //   break;
      case 180:
        text = '3';
        break;
      case 240:
        text = '4';
        break;
      case 300:
        text = '5';
        break;
      case 360:
        text = '6';
        break;
      case 420:
        text = '7';
        break;
      case 480:
        text = '8';
        break;
      case 540:
        text = '9';
        break;
      case 600:
        text = '10';
        break;
      case 720:
        text = '12';
        break;
      case 840:
        text = '14';
        break;
      case 960:
        text = '16';
        break;
      case 1080:
        text = '18';
        break;
      case 1200:
        text = '20';
        break;
      case 1320:
        text = '22';
        break;
      case 1440:
        text = '24';
        break;
      default:
        return Container();
    }
    return Text(
      text,
      style: style,
      textAlign: TextAlign.center,
    );
  }

  //グラフのy軸の数値のみを表示（stackの下に位置）
  LineChartData yAxisData(model) {
    return LineChartData(
      titlesData: FlTitlesData(
        show: true,
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: hiddenTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            //y軸のインターバル
            interval: model.max <= 180
                ? 30
                : model.max <= 360
                    ? 60
                    : 120,
            getTitlesWidget:
                model.num > 1 ? leftTitleWidgets : hiddenTitleWidgets,
            reservedSize: 45,
          ),
        ),
      ),
      //外枠
      borderData: FlBorderData(
        show: false,
      ),
      maxY: model.max <= 180
          ? 180
          : model.max <= 360
              ? 360
              : model.max <= 720
                  ? 720
                  : 1440,
    );
  }

  //グラフのy軸の数値以外のすべてを表示（stackの上に位置）
  LineChartData mainData(model) {
    return LineChartData(
      lineTouchData: LineTouchData(
        // touchTooltipData: LineTouchTooltipData(
        //   tooltipBgColor: Colors.transparent,
        //   getTooltipItems: (touchedSpots) {
        //     return touchedSpots.map((touchedSpot) {
        //       return LineTooltipItem(touchedSpot.y.toString(),
        //           TextStyle(color: Colors.green, fontSize: 15),
        //           children: [
        //             TextSpan(text: "?"),
        //           ]);
        //     }).toList();
        //   },
        // ),
        //タップで数値を表示する
        handleBuiltInTouches: false,
      ),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: model.max <= 180
            //2時間以内
            ? (value) {
                if (value == 30 ||
                    value == 60 ||
                    value == 90 ||
                    value == 120 ||
                    value == 150 ||
                    value == 180) {
                  return FlLine(color: Colors.grey, strokeWidth: 0.5);
                } else {
                  return FlLine(color: Colors.transparent);
                }
              }
            //6時間以内
            : model.max <= 360
                ? (value) {
                    if (value == 60 ||
                        value == 120 ||
                        value == 180 ||
                        value == 240 ||
                        value == 300 ||
                        value == 360 ||
                        value == 420 ||
                        value == 480 ||
                        value == 540 ||
                        value == 600 ||
                        value == 660 ||
                        value == 720) {
                      return FlLine(color: Colors.grey, strokeWidth: 0.5);
                    } else {
                      return FlLine(color: Colors.transparent);
                    }
                  }
                //12時間以上
                : (value) {
                    if (value == 120 ||
                        value == 240 ||
                        value == 360 ||
                        value == 480 ||
                        value == 600 ||
                        value == 720 ||
                        value == 840 ||
                        value == 960 ||
                        value == 1080 ||
                        value == 1200 ||
                        value == 1320 ||
                        value == 1440) {
                      return FlLine(color: Colors.grey, strokeWidth: 0.5);
                    } else {
                      return FlLine(color: Colors.transparent);
                    }
                  },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.transparent,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: hiddenTitleWidgets,
            reservedSize: 45,
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            //xの値が小さい時の値の少数化を防ぐ
            getTitlesWidget: model.num < 10 ? bottomTitleWidgets : null,
            interval: model.num < 10 ? 1 : null,
            reservedSize: 30,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            //y軸のインターバル
            interval: model.max <= 180
                ? 30
                : model.max <= 360
                    ? 60
                    : 120,
            getTitlesWidget: hiddenTitleWidgets,
            reservedSize: 45,
          ),
        ),
      ),
      //外枠（下線）
      borderData: FlBorderData(
        show: true,
        border: Border(
          left: BorderSide(color: Colors.black, width: 0.5),
          bottom: BorderSide(color: Colors.black, width: 0.5),
        ),
      ),
      minX: 1,
      maxX: model.num - 1,
      minY: 0,
      maxY: model.max <= 180
          ? 180
          : model.max <= 360
              ? 360
              : model.max <= 720
                  ? 720
                  : 1440,
      lineBarsData: [
        // 計測時間（緑）
        LineChartBarData(
          show: model.show,
          spots: model.spots1,
          isCurved: true,
          preventCurveOverShooting: true,
          color: Colors.greenAccent.shade700,
          barWidth: 2,
          dotData: FlDotData(show: model.num > 2 ? model.dotSwitch : true
              // show: true
              ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.2))
                  .toList(),
              begin: Alignment.centerLeft,
              end: Alignment.centerLeft,
            ),
          ),
        ),
        // 猫背時間（赤）
        LineChartBarData(
          show: model.show,
          spots: model.spots2,
          isCurved: true,
          preventCurveOverShooting: true,
          color: Colors.deepOrange,
          barWidth: 2,
          dotData: FlDotData(show: model.num > 2 ? model.dotSwitch : true
              // show: true
              ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors2
                  .map((color) => color.withOpacity(0.2))
                  .toList(),
              begin: Alignment.centerLeft,
              end: Alignment.centerLeft,
            ),
          ),
        ),
      ],
      // betweenBarsData: [
      //   BetweenBarsData(
      //     fromIndex: 0,
      //     toIndex: 1,
      //     color: Colors.green.withOpacity(0.2),
      //   )
      // ],
    );
  }
}
