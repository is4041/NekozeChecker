import 'package:fl_chart/fl_chart.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:posture_correction/graph/graph_model.dart';
import 'package:provider/provider.dart';

class GraphPage extends StatelessWidget {
  List<Color> gradientColors = [
    Color(0xffffffff),
    Color(0xff4caf50),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GraphModel>(
        create: (_) => GraphModel()..fetchGraphData(),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                "グラフ",
                style: TextStyle(color: Colors.green),
              ),
              backgroundColor: Colors.white,
            ),
            body: Consumer<GraphModel>(builder: (context, model, child) {
              return Column(
                children: [
                  Container(
                    height: 500,
                    // width: 300,
                    width: double.infinity,
                    decoration:
                        BoxDecoration(border: Border(bottom: BorderSide())),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 30,
                          right: 30,
                          bottom: 30,
                          left: 10,
                        ),
                        child: Container(
                          height: 500,
                          width: 500,
                          // color: Colors.grey[300],
                          child: LineChart(
                            mainData(model),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  // Container(
                  //   child: Text(
                  //     "2022/10",
                  //     style: TextStyle(fontSize: 30),
                  //   ),
                  // )
                ],
              );
            }),
          );
        });
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.green,
      fontSize: 15,
      fontWeight: FontWeight.bold,
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
        text = '(分) 120';
        break;
      default:
        return Container();
    }
    return Text(
      text,
      style: style,
      textAlign: TextAlign.left,
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff68737d),
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      case 2:
        text = const Text('10/2', style: style);
        break;
      case 5:
        text = const Text('10/6', style: style);
        break;
      case 8:
        text = const Text('10/7', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: text,
    );
  }

  LineChartData mainData(model) {
    return LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            if (value == 30 || value == 60 || value == 90) {
              return FlLine(
                color: Colors.grey,
                strokeWidth: 1,
              );
            } else {
              return FlLine(
                color: Colors.grey.withOpacity(0),
                strokeWidth: 1,
              );
            }
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.white.withOpacity(0),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 30,
              getTitlesWidget: leftTitleWidgets,
              reservedSize: 40,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: bottomTitleWidgets,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey, width: 3),
        ),
        minX: 0,
        //横の長さ(何分割するか)
        maxX: 20,
        minY: 0,
        maxY: 120,
        lineBarsData: [
          LineChartBarData(
              spots: model.spots,
              //todo
              // show: model.show,
              isCurved: false,
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerLeft,
              ),
              barWidth: 5,
              isStrokeCapRound: false,
              dotData: FlDotData(
                show: true,
              ),
              belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: gradientColors
                        .map((color) => color.withOpacity(0.2))
                        .toList(),
                    begin: Alignment.centerLeft,
                    end: Alignment.centerLeft,
                  ))),
        ]);
  }
}
