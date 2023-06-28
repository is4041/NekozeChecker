import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:posture_correction/history/history_model.dart';
import 'package:provider/provider.dart';

import '../data.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return ChangeNotifierProvider<HistoryModel>(
        create: (_) => HistoryModel()..fetchData(),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.grey[50],
              title: Text(
                "履  歴",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent.shade700),
              ),
            ),
            body: Consumer<HistoryModel>(builder: (context, model, child) {
              final style = TextStyle(fontSize: 17);
              final List<Data>? data = model.data;
              return Stack(
                children: [
                  Scrollbar(
                    child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: data!.length,
                        itemBuilder: (BuildContext context, int index) {
                          //日付を取得
                          String createdAt = data[index].createdAt!;
                          //計測時間を時・分・秒に変換
                          num measuringSec = data[index].measuringSec!;
                          num measuringHourValue = measuringSec ~/ 60 ~/ 60;
                          num measuringMinuteValue = measuringSec ~/ 60 % 60;
                          num measuringSecondValue = measuringSec % 60;
                          //姿勢（不良）を時・分・秒に変換
                          num measuringBadPostureSec =
                              data[index].measuringBadPostureSec!;
                          num badHourValue = measuringBadPostureSec ~/ 60 ~/ 60;
                          num badMinuteValue =
                              measuringBadPostureSec ~/ 60 % 60;
                          num badSecondValue = measuringBadPostureSec % 60;
                          //姿勢（良）を時・分・秒に変換
                          num measuringGoodPostureSec =
                              (measuringSec - measuringBadPostureSec);
                          num goodHourValue =
                              measuringGoodPostureSec ~/ 60 ~/ 60;
                          num goodMinuteValue =
                              measuringGoodPostureSec ~/ 60 % 60;
                          num goodSecondValue = measuringGoodPostureSec % 60;
                          //警告音カウント回数
                          num notificationCounter =
                              data[index].notificationCounter!;
                          //設定した警告音通知までの秒数
                          int timeToNotification =
                              data[index].timeToNotification!;
                          //姿勢（良）の割合を取得
                          num rateOfGoodPosture = double.parse(
                              ((measuringGoodPostureSec / measuringSec) * 100)
                                  .toStringAsFixed(1));
                          return Container(
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        width: 1, color: Colors.grey))),
                            child: ListTile(
                              onTap: () {
                                TextEditingController titleController =
                                    TextEditingController();
                                titleController.text = data[index].memo!;
                                //textFieldの入力内容の保存に関する意図しない処理を回避
                                model.memo = data[index].memo!.toString();

                                //モーダルダイアログ
                                showModalBottomSheet(
                                    backgroundColor: Colors.transparent,
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (BuildContext context) {
                                      //履歴詳細
                                      return InkWell(
                                        onTap: () {
                                          FocusScope.of(context).unfocus();
                                        },
                                        child: Container(
                                          height: screenSize.height * 0.8,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(30),
                                              topRight: Radius.circular(30),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                color:
                                                    Colors.greenAccent.shade700,
                                                height: 60,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      width: 70,
                                                      child: Center(
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Icon(
                                                            Icons.close,
                                                            color: Colors.grey,
                                                          ),
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                                  shape:
                                                                      CircleBorder(),
                                                                  primary: Colors
                                                                      .white),
                                                        ),
                                                      ),
                                                    ),
                                                    Center(
                                                      child: Text(
                                                        "履歴詳細",
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 70,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  keyboardDismissBehavior:
                                                      ScrollViewKeyboardDismissBehavior
                                                          .onDrag,
                                                  child: Column(
                                                    children: [
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          " メモ",
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 40,
                                                        width: double.infinity,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          border: Border(
                                                            top: BorderSide(
                                                                color:
                                                                    Colors.grey,
                                                                width: 0.5),
                                                            bottom: BorderSide(
                                                                color:
                                                                    Colors.grey,
                                                                width: 0.5),
                                                          ),
                                                        ),
                                                        //メモ入力フィールド
                                                        child: TextField(
                                                          onChanged: (text) {
                                                            model.memo = text;
                                                          },
                                                          controller:
                                                              titleController,
                                                          inputFormatters: [
                                                            LengthLimitingTextInputFormatter(
                                                              20,
                                                            )
                                                          ],
                                                          decoration:
                                                              InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.only(
                                                                    top: 5),
                                                            prefixIcon: Icon(
                                                                Icons.edit),
                                                            border: InputBorder
                                                                .none,
                                                          ),
                                                        ),
                                                      ),
                                                      //メモの内容を保存するボタン
                                                      Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  right: 5.0),
                                                          child: ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                await model
                                                                    .updateTitle(
                                                                        data[
                                                                            index]);
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                primary: Colors
                                                                    .greenAccent
                                                                    .shade700,
                                                              ),
                                                              child:
                                                                  Text("保存")),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 30,
                                                      ),
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          " 計測データ",
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                      ),
                                                      Container(
                                                        padding: EdgeInsets.all(
                                                            10.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          border: Border(
                                                            top: BorderSide(
                                                                color:
                                                                    Colors.grey,
                                                                width: 0.5),
                                                            bottom: BorderSide(
                                                                color:
                                                                    Colors.grey,
                                                                width: 0.5),
                                                          ),
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            //計測No.を表示
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text("計測No.",
                                                                    style:
                                                                        style),
                                                                Text(
                                                                  "No.${data.length - index}",
                                                                  style: style,
                                                                ),
                                                              ],
                                                            ),
                                                            Divider(),
                                                            //計測日を表示
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text("計測日",
                                                                    style:
                                                                        style),
                                                                Text(
                                                                    createdAt.substring(
                                                                            0, 4) +
                                                                        "年" +
                                                                        createdAt.substring(
                                                                            5,
                                                                            7) +
                                                                        "月" +
                                                                        createdAt.substring(
                                                                            8,
                                                                            10) +
                                                                        "日",
                                                                    style:
                                                                        style),
                                                              ],
                                                            ),
                                                            Divider(),
                                                            //計測時間を表示
                                                            TimeValue(
                                                              posture: "",
                                                              hourValue:
                                                                  measuringHourValue,
                                                              minuteValue:
                                                                  measuringMinuteValue,
                                                              secondValue:
                                                                  measuringSecondValue,
                                                              style: TextStyle(
                                                                  fontSize: 17,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            Divider(),
                                                            //計測時間（姿勢・良）を表示
                                                            TimeValue(
                                                              posture: "（姿勢・良）",
                                                              hourValue:
                                                                  goodHourValue,
                                                              minuteValue:
                                                                  goodMinuteValue,
                                                              secondValue:
                                                                  goodSecondValue,
                                                              style: TextStyle(
                                                                fontSize: 17,
                                                                color: Colors
                                                                    .greenAccent
                                                                    .shade700,
                                                              ),
                                                            ),
                                                            Divider(),
                                                            //計測時間（姿勢・不良）を表示
                                                            TimeValue(
                                                              posture:
                                                                  "（姿勢・不良）",
                                                              hourValue:
                                                                  badHourValue,
                                                              minuteValue:
                                                                  badMinuteValue,
                                                              secondValue:
                                                                  badSecondValue,
                                                              style: TextStyle(
                                                                fontSize: 17,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                            ),
                                                            Divider(),
                                                            //警告音が鳴った回数を表示
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  timeToNotification ~/
                                                                              60 >
                                                                          0
                                                                      ? "警告回数（設定：${(timeToNotification / 60).floor()}分）"
                                                                      : "警告回数（設定：$timeToNotification秒）",
                                                                  style: style,
                                                                ),
                                                                Text(
                                                                  "$notificationCounter回",
                                                                  style: style,
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 80,
                                                      ),
                                                      //データ削除ボタン
                                                      InkWell(
                                                        onTap: () async {
                                                          await showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return CupertinoAlertDialog(
                                                                title: Text(
                                                                    "データ削除"),
                                                                content: Text(
                                                                    "計測データの平均値が変化しますが\nデータを削除しますか？"),
                                                                actions: [
                                                                  TextButton(
                                                                    child:
                                                                        const Text(
                                                                      "削除",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.red),
                                                                    ),
                                                                    onPressed:
                                                                        () async {
                                                                      try {
                                                                        await model
                                                                            .delete(data[index]);
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                        final snackBar =
                                                                            SnackBar(
                                                                          backgroundColor:
                                                                              Colors.red,
                                                                          content:
                                                                              Text("削除しました"),
                                                                        );
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(snackBar);
                                                                      } catch (e) {
                                                                        await showDialog(
                                                                            barrierColor: Colors
                                                                                .transparent,
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (BuildContext context) {
                                                                              return CupertinoAlertDialog(
                                                                                title: Text("エラー"),
                                                                                content: Text(e.toString()),
                                                                                actions: [
                                                                                  TextButton(
                                                                                    child: Text(
                                                                                      "OK",
                                                                                    ),
                                                                                    onPressed: () {
                                                                                      Navigator.of(context).pop();
                                                                                    },
                                                                                  ),
                                                                                ],
                                                                              );
                                                                            });
                                                                      }
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  ),
                                                                  TextButton(
                                                                    child: Text(
                                                                        "キャンセル"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        },
                                                        child: Container(
                                                          height: 40,
                                                          width:
                                                              double.infinity,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            border: Border(
                                                              top: BorderSide(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: 0.5),
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: 0.5),
                                                            ),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              "データ削除",
                                                              style: TextStyle(
                                                                  fontSize: 17,
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 50,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                              },
                              //履歴
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //No.を表示
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "No.${data.length - index}",
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                  //日付を表示
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        createdAt.substring(0, 4) +
                                            "/ " +
                                            createdAt.substring(5, 7) +
                                            "/ " +
                                            createdAt.substring(8, 10),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      //計測時間を表示
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "計測時間",
                                              style: TextStyle(
                                                fontSize: 11,
                                              ),
                                            ),
                                            Wrap(
                                              children: [
                                                timeValue(measuringHourValue,
                                                    "時間", Colors.black),
                                                timeValue(measuringMinuteValue,
                                                    "分", Colors.black),
                                                timeValue(measuringSecondValue,
                                                    "秒", Colors.black),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      //計測時間（姿勢・良）を表示
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "姿勢",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                Text(
                                                  "(良)",
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.greenAccent
                                                          .shade700),
                                                ),
                                              ],
                                            ),
                                            Wrap(
                                              children: [
                                                timeValue(
                                                    goodHourValue,
                                                    "時間",
                                                    Colors
                                                        .greenAccent.shade700),
                                                timeValue(
                                                    goodMinuteValue,
                                                    "分",
                                                    Colors
                                                        .greenAccent.shade700),
                                                timeValue(
                                                    goodSecondValue,
                                                    "秒",
                                                    Colors
                                                        .greenAccent.shade700),
                                                //無表示を防ぐ
                                                Visibility(
                                                  visible:
                                                      measuringGoodPostureSec ==
                                                          0,
                                                  child: Text(
                                                    "0秒",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors
                                                            .greenAccent
                                                            .shade700,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      //計測時間（姿勢・良）の割合を表示、割合に応じて色を変化
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "姿勢",
                                                  style:
                                                      TextStyle(fontSize: 13),
                                                ),
                                                Text(
                                                  "(良)",
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.greenAccent
                                                          .shade700),
                                                ),
                                                Text(
                                                  "率",
                                                  style:
                                                      TextStyle(fontSize: 13),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              "$rateOfGoodPosture％",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: rateOfGoodPosture >= 90
                                                      //90%以上
                                                      ? Colors
                                                          .greenAccent.shade700
                                                      : rateOfGoodPosture >= 80
                                                          //80%以上
                                                          ? Color(0xFF2BD600)
                                                          : rateOfGoodPosture >=
                                                                  70
                                                              //70%以上
                                                              ? Color(
                                                                  0xFF58DB00)
                                                              : rateOfGoodPosture >=
                                                                      60
                                                                  //60%以上
                                                                  ? Color(
                                                                      0xFF88E200)
                                                                  : rateOfGoodPosture >=
                                                                          50
                                                                      //50%以上
                                                                      ? Color(
                                                                          0xFFBFE600)
                                                                      : rateOfGoodPosture >=
                                                                              40
                                                                          //40%以上
                                                                          ? Color(
                                                                              0xFFEBDB00)
                                                                          : rateOfGoodPosture >= 30
                                                                              //30%以上
                                                                              ? Color(0xFFF0A800)
                                                                              : rateOfGoodPosture >= 20
                                                                                  //20%以上
                                                                                  ? Color(0xFFF57200)
                                                                                  : rateOfGoodPosture >= 10
                                                                                      //10%以上
                                                                                      ? Color(0xFFFA3A00)
                                                                                      //10%未満
                                                                                      : Color(0xFFFF0000)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                    child: Text(
                                      "${data[index].memo}",
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.grey),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                  //ローディング中のインジケータ
                  if (model.isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                ],
              );
            }),
          );
        });
  }
}

//履歴詳細の時間の表示
class TimeValue extends StatelessWidget {
  TimeValue({
    required this.posture,
    required this.hourValue,
    required this.minuteValue,
    required this.secondValue,
    required this.style,
  });
  final String posture;
  final num hourValue;
  final num minuteValue;
  final num secondValue;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("計測時間${(posture)}", style: style),
        Row(
          children: [
            Text(hourValue > 0 ? "$hourValue時間" : "", style: style),
            Text(minuteValue > 0 ? "$minuteValue分" : "", style: style),
            Text(
              secondValue > 0 ? "$secondValue秒" : "",
              style: style,
            ),
            Visibility(
              visible: hourValue == 0 && minuteValue == 0 && secondValue == 0,
              child: Text("0秒", style: style),
            ),
          ],
        ),
      ],
    );
  }
}

//履歴の時間の表示
Widget timeValue(time, timeUnit, color) {
  return Text(
    time > 0 ? "$time$timeUnit" : "",
    style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w600),
  );
}
