import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

//グラフのy軸の値　表示は時間(h)で内部の数値は分(m)
Widget leftTitleWidgets(double value, TitleMeta meta) {
  const style = TextStyle(
    color: Colors.black,
    fontSize: 15,
  );
  String text;
  switch (value.toInt()) {
    case 60:
      text = '1';
      break;
    case 120:
      text = '2';
      break;
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

//x軸の値が10以下の時に適用
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
    case 9:
      text = '9';
      break;
    case 10:
      text = '10';
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

//x軸の値が20以下の時に適用
Widget bottomTitleWidgets2(double value, TitleMeta meta) {
  const style = TextStyle(
    color: Colors.black,
    fontSize: 14,
  );
  String text;
  switch (value.toInt()) {
    case 1:
      text = '';
      break;
    case 2:
      text = '2';
      break;
    case 4:
      text = '4';
      break;
    case 6:
      text = '6';
      break;
    case 8:
      text = '8';
      break;
    case 10:
      text = '10';
      break;
    case 12:
      text = '12';
      break;
    case 14:
      text = '14';
      break;
    case 16:
      text = '16';
      break;
    case 18:
      text = '18';
      break;
    case 20:
      text = '20';
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

//x軸の値が30以下の時に適用
Widget bottomTitleWidgets3(double value, TitleMeta meta) {
  const style = TextStyle(
    color: Colors.black,
    fontSize: 14,
  );
  String text;
  switch (value.toInt()) {
    case 1:
      text = '';
      break;
    case 3:
      text = '3';
      break;
    case 6:
      text = '6';
      break;
    case 9:
      text = '9';
      break;
    case 12:
      text = '12';
      break;
    case 15:
      text = '15';
      break;
    case 18:
      text = '18';
      break;
    case 21:
      text = '21';
      break;
    case 24:
      text = '24';
      break;
    case 27:
      text = '27';
      break;
    case 30:
      text = '30';
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

//x軸の値が40以下の時に適用
Widget bottomTitleWidgets4(double value, TitleMeta meta) {
  const style = TextStyle(
    color: Colors.black,
    fontSize: 14,
  );
  String text;
  switch (value.toInt()) {
    case 1:
      text = '';
      break;
    case 4:
      text = '4';
      break;
    case 8:
      text = '8';
      break;
    case 12:
      text = '12';
      break;
    case 16:
      text = '16';
      break;
    case 20:
      text = '20';
      break;
    case 24:
      text = '24';
      break;
    case 28:
      text = '28';
      break;
    case 32:
      text = '32';
      break;
    case 36:
      text = '36';
      break;
    case 40:
      text = '40';
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

//x軸の値が50以下の時に適用
Widget bottomTitleWidgets5(double value, TitleMeta meta) {
  const style = TextStyle(
    color: Colors.black,
    fontSize: 14,
  );
  String text;
  switch (value.toInt()) {
    case 1:
      text = '';
      break;
    case 5:
      text = '5';
      break;
    case 10:
      text = '10';
      break;
    case 15:
      text = '15';
      break;
    case 20:
      text = '20';
      break;
    case 25:
      text = '25';
      break;
    case 30:
      text = '30';
      break;
    case 35:
      text = '35';
      break;
    case 40:
      text = '40';
      break;
    case 45:
      text = '45';
      break;
    case 50:
      text = '50';
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
