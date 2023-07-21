import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:posture_correction/graph/graph_model.dart';
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
            final height = screenSize.height * 0.5;
            final width = model.extendWidth && model.num * 50 > screenSize.width
                ? model.num * 50
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
                              color: Colors.greenAccent.shade700,
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
                                        model.data.isNotEmpty
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
                                    primary: Colors.greenAccent.shade700),
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
                              num measuringSec =
                                  model.data[index]["measuringSec"];
                              num hourValue = measuringSec ~/ 60 ~/ 60;
                              num minuteValue = measuringSec ~/ 60 % 60;
                              num secondValue = measuringSec % 60;
                              //姿勢（良）を時・分・秒に変換
                              num measuringGoodPostureSec =
                                  model.data[index]["measuringGoodPostureSec"];
                              num goodHourValue =
                                  measuringGoodPostureSec ~/ 60 ~/ 60;
                              num goodMinuteValue =
                                  measuringGoodPostureSec ~/ 60 % 60;
                              num goodSecondValue =
                                  measuringGoodPostureSec % 60;
                              //姿勢（不良）を時・分・秒に変換
                              num measuringBadPostureSec =
                                  model.data[index]["measuringBadPostureSec"];
                              num badHourValue =
                                  measuringBadPostureSec ~/ 60 ~/ 60;
                              num badMinuteValue =
                                  measuringBadPostureSec ~/ 60 % 60;
                              num badSecondValue = measuringBadPostureSec % 60;
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
                                      TimeValue(
                                          hourValue: hourValue,
                                          minuteValue: minuteValue,
                                          secondValue: secondValue,
                                          color: Colors.black),
                                      //計測時間（姿勢・良）
                                      TimeValue(
                                        hourValue: goodHourValue,
                                        minuteValue: goodMinuteValue,
                                        secondValue: goodSecondValue,
                                        color: Colors.greenAccent.shade700,
                                      ),
                                      //計測時間（姿勢・不良）
                                      TimeValue(
                                          hourValue: badHourValue,
                                          minuteValue: badMinuteValue,
                                          secondValue: badSecondValue,
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

  //不要な数値非表示のためのウィジェット
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
      //処理の負荷軽減のためグラフの値は計測秒数の1/100で表示
      case 36:
        text = '1';
        break;
      case 72:
        text = '2';
        break;
      case 108:
        text = '3';
        break;
      case 144:
        text = '4';
        break;
      case 180:
        text = '5';
        break;
      case 216:
        text = '6';
        break;
      case 252:
        text = '7';
        break;
      case 288:
        text = '8';
        break;
      case 324:
        text = '9';
        break;
      case 360:
        text = '10';
        break;
      case 432:
        text = '12';
        break;
      case 504:
        text = '14';
        break;
      case 576:
        text = '16';
        break;
      case 648:
        text = '18';
        break;
      case 720:
        text = '20';
        break;
      case 792:
        text = '22';
        break;
      case 864:
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
            //y軸のインターバル
            //処理の負荷軽減のためグラフの値は計測秒数の1/100で表示
            interval: model.max <= 108
                ? 18
                : model.max <= 216
                    ? 36
                    : 72,
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
      //処理の負荷軽減のためグラフの値は計測秒数の1/100で表示
      maxY: model.max <= 108
          ? 108
          : model.max <= 216
              ? 216
              : model.max <= 432
                  ? 432
                  : 864,
    );
  }

  //グラフのy軸の数値以外のすべてを表示（stackの上に位置）
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
        getDrawingHorizontalLine: model.max <= 108
            //処理の負荷軽減のためグラフの値は計測秒数の1/100で表示
            //3時間以内
            ? (value) {
                if (value == 18 ||
                    value == 36 ||
                    value == 54 ||
                    value == 72 ||
                    value == 90 ||
                    value == 108) {
                  return FlLine(color: Colors.grey, strokeWidth: 0.5);
                } else {
                  return FlLine(color: Colors.transparent);
                }
              }
            //6時間以内
            : model.max <= 216
                ? (value) {
                    if (value == 36 ||
                        value == 72 ||
                        value == 108 ||
                        value == 144 ||
                        value == 180 ||
                        value == 216 ||
                        value == 252 ||
                        value == 288 ||
                        value == 324 ||
                        value == 360 ||
                        value == 396 ||
                        value == 432) {
                      return FlLine(color: Colors.grey, strokeWidth: 0.5);
                    } else {
                      return FlLine(color: Colors.transparent);
                    }
                  }
                //12時間以上
                : (value) {
                    if (value == 72 ||
                        value == 144 ||
                        value == 216 ||
                        value == 288 ||
                        value == 360 ||
                        value == 432 ||
                        value == 504 ||
                        value == 576 ||
                        value == 648 ||
                        value == 720 ||
                        value == 792 ||
                        value == 864) {
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
            //処理の負荷軽減のためグラフの値は計測秒数の1/100で表示
            interval: model.max <= 108
                ? 18
                : model.max <= 216
                    ? 36
                    : 72,
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
      //処理の負荷軽減のためグラフの値は計測秒数の1/100で表示
      maxY: model.max <= 108
          ? 108
          : model.max <= 216
              ? 216
              : model.max <= 432
                  ? 432
                  : 864,
      lineBarsData: [
        // 計測時間（姿勢・良）
        LineChartBarData(
          show: model.show,
          spots: model.spots1,
          isCurved: true,
          color: Colors.greenAccent.shade700,
          barWidth: 3,
          dotData: FlDotData(show: model.num > 2 ? model.dotSwitch : true
              // show: true
              ),
        ),
        // 計測時間（姿勢・不良）
        LineChartBarData(
          show: model.show,
          spots: model.spots2,
          isCurved: true,
          color: Colors.deepOrange,
          barWidth: 3,
          dotData: FlDotData(show: model.num > 2 ? model.dotSwitch : true
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
        )
      ],
    );
  }
}

class TimeValue extends StatelessWidget {
  TimeValue({
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
