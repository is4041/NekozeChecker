import 'package:fl_chart/fl_chart.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:posture_correction/graph/graph_model.dart';
import 'package:provider/provider.dart';

import 'dart:math';
import '../data.dart';

class GraphPage extends StatelessWidget {
  List<Color> gradientColors = [
    Color(0xff9aee9b),
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
            return Scaffold(
                appBar: AppBar(
                  title: Column(
                    children: [
                      // Text(
                      //   "グラフ",
                      //   style: TextStyle(fontSize: 13, color: Colors.green),
                      // ),
                      Row(
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
                              model.month!,
                              style: TextStyle(
                                fontSize: 25.0, color: Colors.green,
                                // fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Transform.rotate(
                            angle: 180 * pi / 180,
                            child: IconButton(
                              onPressed: () {
                                model.getNextMonthData();
                              },
                              icon: Icon(Icons.arrow_back_ios_outlined),
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  backgroundColor: Colors.white,
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
                            Container(
                              height: screenSize.height * 0.5,
                              width: model.extendWidth &&
                                      model.num * 50 > screenSize.width
                                  ? model.num * 50
                                  : screenSize.width,
                              // color: Colors.grey[300],
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
                                "(分)",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              )),
                            ),
                            // ),
                          ],
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Stack(
                            children: [
                              Container(
                                height: screenSize.height * 0.5,
                                width: model.extendWidth &&
                                        model.num * 50 > screenSize.width
                                    ? model.num * 50
                                    : screenSize.width,
                                // color: Colors.grey[300],
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 25.0),
                                  child: LineChart(
                                    mainData(model),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                model.changes2();
                              },
                              child: Transform.rotate(
                                  angle: model.switchWidthIcon
                                      ? 0
                                      : 180 * pi / 180,
                                  child: Icon(Icons.arrow_back_ios_outlined)),
                              style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(), primary: Colors.green),
                            ),
                          ),
                        ),
                        if (model.num < 2)
                          Padding(
                            padding: const EdgeInsets.only(top: 200.0),
                            child: Center(
                              child: Container(
                                height: 60,
                                width: 250,
                                child: Center(
                                  child: Text(
                                    "NO DATA",
                                    style: TextStyle(
                                        fontSize: 40, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Container(
                      height: 15,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        border: Border(
                          top: BorderSide(color: Colors.grey),
                          bottom: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: model.data1.length,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.black12),
                              ),
                            ),
                            child: ListTile(
                              title: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${index + 1}.",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            model.data1[index]["createdAt"]
                                                .toString(),
                                            style: TextStyle(
                                                fontSize: 15.0,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        "${model.data1[index]["measuringMin"]}分",
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "${model.data1[index]["measuringBadPostureMin"]}分",
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // subtitle:
                              //     Text(model.data[index]["createdAt"].toString()),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ));
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
      case 30:
        text = '30';
        break;
      case 60:
        text = '60';
        break;
      case 90:
        text = '90';
        break;
      case 120:
        text = '120';
        break;
      case 150:
        text = '150';
        break;
      case 180:
        text = '180';
        break;
      case 210:
        text = '210';
        break;
      case 240:
        text = '240';
        break;
      case 270:
        text = '270';
        break;
      case 300:
        text = '300';
        break;
      case 330:
        text = '330';
        break;
      case 360:
        text = '360';
        break;
      case 420:
        text = '420';
        break;
      case 480:
        text = '480';
        break;
      case 540:
        text = '540';
        break;
      case 600:
        text = '600';
        break;
      case 660:
        text = '660';
        break;
      case 720:
        text = '720';
        break;
      case 840:
        text = '840';
        break;
      case 960:
        text = '960';
        break;
      case 1080:
        text = '1080';
        break;
      case 1200:
        text = '1200';
        break;
      case 1320:
        text = '1320';
        break;
      case 1440:
        text = '1440';
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
            interval: model.max <= 720 ? (model.max <= 360 ? 30 : 60) : 120,
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
      maxY: model.max <= 720
          ? (model.max <= 360 ? model.max + 30 : model.max + 60)
          : 1440,
    );
  }

  //グラフのy軸の数値以外のすべてを表示（stackの上に位置）
  LineChartData mainData(model) {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.transparent,
        ),
        handleBuiltInTouches: true,
      ),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: model.max <= 720
            ? (model.max <= 360
                //最大数値360分以下でインターバル　30分
                ? (value) {
                    if (value == 30 ||
                        value == 60 ||
                        value == 90 ||
                        value == 120 ||
                        value == 150 ||
                        value == 180 ||
                        value == 210 ||
                        value == 240 ||
                        value == 270 ||
                        value == 300 ||
                        value == 330 ||
                        value == 360) {
                      return FlLine(color: Colors.grey, strokeWidth: 0.5);
                    } else {
                      return FlLine(color: Colors.transparent);
                    }
                  }
                //最大数値361分以上720分以下でインターバル　1時間
                : (value) {
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
                  })
            //最大数値721分以上でインターバル　2時間
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
            interval: model.max <= 720 ? (model.max <= 360 ? 30 : 60) : 120,
            getTitlesWidget: hiddenTitleWidgets,
            reservedSize: 45,
          ),
        ),
      ),
      //外枠（下線）
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 0.5),
        ),
      ),
      minX: 1,
      maxX: model.num - 1,
      minY: 0,
      maxY: model.max <= 720
          ? (model.max <= 360 ? model.max + 30 : model.max + 60)
          : 1440,
      lineBarsData: [
        // 計測時間（緑）
        LineChartBarData(
          show: model.show,
          spots: model.spots1,
          isCurved: true,
          color: Colors.green[300],
          barWidth: 2,
          isStrokeCapRound: true,
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
              // begin: Alignment.centerRight,
              // end: Alignment.centerRight,
            ),
          ),
        ),
        // 猫背時間（赤）
        LineChartBarData(
          show: model.show,
          spots: model.spots2,
          isCurved: true,
          color: Colors.deepOrange,
          barWidth: 2,
          isStrokeCapRound: true,
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
    );
  }
}
