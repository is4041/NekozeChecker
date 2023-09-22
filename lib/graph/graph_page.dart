import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:posture_correction/graph/graph_model.dart';
import 'package:posture_correction/graph/title_widget.dart';
import 'package:posture_correction/utils.dart';
import 'package:provider/provider.dart';

import 'dart:math';

class GraphPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return ChangeNotifierProvider<GraphModel>(
        create: (_) => GraphModel()..fetchGraphData(),
        builder: (context, snapshot) {
          return Consumer<GraphModel>(builder: (context, model, child) {
            final height = screenSize.height * 0.45;
            final width =
                model.extendWidth && (model.num + 1) * 50 > screenSize.width
                    ? (model.num + 1) * 50
                    : screenSize.width;
            return Stack(
              children: [
                Scaffold(
                  //日付表示
                  appBar: AppBar(
                    elevation: 0,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        //先月のデータ取得ボタン
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
                              color: model.data.isNotEmpty
                                  ? Colors.greenAccent.shade700
                                  : Colors.grey,
                              // fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        //翌月のデータ取得ボタン
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
                      //
                      Stack(
                        children: [
                          Stack(
                            children: [
                              //グラフのy軸の値のみ表示
                              Container(
                                height: height,
                                width: width,
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
                              //y軸の単位
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
                          //グラフ全体（y軸の値以外）を表示
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              height: height,
                              width: width,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 25.0),
                                child: LineChart(
                                  mainData(model),
                                ),
                              ),
                            ),
                          ),
                          //表示されているデータの姿勢（良）と姿勢（不良）の割合
                          model.data.isNotEmpty
                              ? Align(
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
                                                  color: Colors
                                                      .greenAccent.shade700,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              model.rateOfGoodPosture != 0
                                                  ? "：${model.rateOfGoodPosture}％"
                                                  : "：0％",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors
                                                      .greenAccent.shade700),
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
                                              model.data.isNotEmpty
                                                  ? "：${(100 - model.rateOfGoodPosture).toStringAsFixed(1)}％"
                                                  : "：0％",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.red),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                  Utils.nekoMode == true ? "データにゃし" : "データなし",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                )),
                          //グラフを延長表示するボタン
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
                                    backgroundColor:
                                        Colors.greenAccent.shade700),
                              ),
                            ),
                          ),
                        ],
                      ),
                      //x軸の単位
                      Container(
                        alignment: Alignment.topRight,
                        height: 20,
                        child: Text(
                          "(回目)",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                      //計測No.　計測時間　姿勢(良)　姿勢(不)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border(
                            bottom: BorderSide(color: Colors.grey),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: Text(
                                  "計測No.",
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
                                    "(猫背)",
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
                              num _measuringSec =
                                  model.data[index]["measuringSec"];
                              num _hourValue = _measuringSec ~/ 60 ~/ 60;
                              num _minuteValue = _measuringSec ~/ 60 % 60;
                              num _secondValue = _measuringSec % 60;
                              //姿勢（良）を時・分・秒に変換
                              num _measuringGoodPostureSec =
                                  model.data[index]["measuringGoodPostureSec"];
                              num _goodHourValue =
                                  _measuringGoodPostureSec ~/ 60 ~/ 60;
                              num _goodMinuteValue =
                                  _measuringGoodPostureSec ~/ 60 % 60;
                              num _goodSecondValue =
                                  _measuringGoodPostureSec % 60;
                              //姿勢（不良）を時・分・秒に変換
                              num _measuringBadPostureSec =
                                  model.data[index]["measuringBadPostureSec"];
                              num _badHourValue =
                                  _measuringBadPostureSec ~/ 60 ~/ 60;
                              num _badMinuteValue =
                                  _measuringBadPostureSec ~/ 60 % 60;
                              num _badSecondValue =
                                  _measuringBadPostureSec % 60;
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  "${model.data.length - index}",
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
                                      //計測時間
                                      _TimeValue(
                                          hourValue: _hourValue,
                                          minuteValue: _minuteValue,
                                          secondValue: _secondValue,
                                          color: Colors.black),
                                      //計測時間（姿勢・良）
                                      _TimeValue(
                                        hourValue: _goodHourValue,
                                        minuteValue: _goodMinuteValue,
                                        secondValue: _goodSecondValue,
                                        color: Colors.greenAccent.shade700,
                                      ),
                                      //計測時間（姿勢・不良）
                                      _TimeValue(
                                          hourValue: _badHourValue,
                                          minuteValue: _badMinuteValue,
                                          secondValue: _badSecondValue,
                                          color: Colors.red),
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
                //ローディング中のインジケータ
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

  //グラフのy軸の値のみを表示（stackの下に位置）
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
            //y軸のインターバル（単位：分）
            interval: model.max <= 180
                ? 30
                : model.max <= 360
                    ? 60
                    : 120,
            getTitlesWidget:
                model.num > 0 ? leftTitleWidgets : hiddenTitleWidgets,
            reservedSize: 45,
          ),
        ),
      ),
      //外枠
      borderData: FlBorderData(
        show: false,
      ),
      minY: 0,
      //y軸の最大値（単位：分）
      maxY: model.max <= 180
          ? 180
          : model.max <= 360
              ? 360
              : model.max <= 720
                  ? 720
                  : 1440,
    );
  }

  //グラフのy軸の値以外のすべてを表示（stackの上に位置）
  LineChartData mainData(model) {
    return LineChartData(
      lineTouchData: LineTouchData(
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
            //最長計測時間が3時間以内の場合
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
            //最長計測時間が6時間以内の場合
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
                //最長計測時間が12時間以上の場合
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
            //model.numの数量によって数値の表示を変える
            getTitlesWidget: model.extendWidth == false
                ? (model.num <= 10
                    ? bottomTitleWidgets
                    : model.num <= 20
                        ? bottomTitleWidgets2
                        : model.num <= 30
                            ? bottomTitleWidgets3
                            : model.num <= 40
                                ? bottomTitleWidgets4
                                : model.num <= 50
                                    ? bottomTitleWidgets5
                                    : defaultGetTitle)
                : model.num <= 10
                    ? bottomTitleWidgets
                    : defaultGetTitle,
            interval: model.extendWidth == false
                ? (model.num <= 10
                    ? 1
                    : model.num <= 20
                        ? 2
                        : model.num <= 30
                            ? 3
                            : model.num <= 40
                                ? 4
                                : model.num <= 50
                                    ? 5
                                    : null)
                : model.num <= 10
                    ? 1
                    : null,
            reservedSize: 30,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
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
      maxX: model.num,
      minY: 0,
      //y軸の最大値（単位：分）
      maxY: model.max <= 180
          ? 180
          : model.max <= 360
              ? 360
              : model.max <= 720
                  ? 720
                  : 1440,
      lineBarsData: [
        // 計測時間（姿勢・良）
        LineChartBarData(
          show: model.show,
          spots: model.show ? model.spots1 : [],
          isCurved: true,
          color: Colors.greenAccent.shade700,
          barWidth: 3,
          dotData: FlDotData(show: model.num > 1 ? model.dotSwitch : true
              // show: true
              ),
        ),
        // 計測時間（姿勢・不良）
        LineChartBarData(
          show: model.show,
          spots: model.show ? model.spots2 : [],
          isCurved: true,
          color: Colors.deepOrange,
          barWidth: 3,
          dotData: FlDotData(show: model.num > 1 ? model.dotSwitch : true
              // show: true
              ),
          belowBarData: BarAreaData(
              show: true, color: Colors.deepOrange.withOpacity(0.2)),
        ),
      ],
      betweenBarsData: [
        BetweenBarsData(
          fromIndex: 0,
          toIndex: 1,
          color: Colors.greenAccent.shade700.withOpacity(0.2),
        ),
      ],
    );
  }
}

class _TimeValue extends StatelessWidget {
  _TimeValue({
    required this.hourValue,
    required this.minuteValue,
    required this.secondValue,
    required this.color,
  });

  final num hourValue;
  final num minuteValue;
  final num secondValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.end,
        alignment: WrapAlignment.end,
        children: [
          Text(
            hourValue > 0 ? "$hourValue" : "",
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500, color: color),
          ),
          Text(
            hourValue > 0 ? "時間" : "",
            style: TextStyle(fontSize: 12, color: color),
          ),
          Text(
            minuteValue > 0 ? "$minuteValue" : "",
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500, color: color),
          ),
          Text(
            minuteValue > 0 ? "分" : "",
            style: TextStyle(fontSize: 12, color: color),
          ),
          Text(
            secondValue > 0 ? "$secondValue" : "",
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500, color: color),
          ),
          Text(
            secondValue > 0 ? "秒" : "",
            style: TextStyle(fontSize: 12, color: color),
          ),
          Visibility(
            visible: hourValue == 0 && minuteValue == 0 && secondValue == 0,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              alignment: WrapAlignment.end,
              children: [
                Text("0",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: color)),
                Text("秒", style: TextStyle(fontSize: 12, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
