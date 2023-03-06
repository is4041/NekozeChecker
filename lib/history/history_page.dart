import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
              const style = TextStyle(fontSize: 17);
              const styleGreen = TextStyle(fontSize: 17, color: Colors.green);
              const styleRed = TextStyle(fontSize: 17, color: Colors.red);
              final List<Data>? data = model.data;
              return Stack(
                children: [
                  Scrollbar(
                    child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: data!.length,
                        itemBuilder: (BuildContext context, int index) {
                          //日付
                          String createdAt = data[index].createdAt!;
                          //姿勢（良）を時・分・秒に変換
                          num measuringHourValue =
                              data[index].measuringSec! ~/ 60 ~/ 60;
                          num measuringMinuteValue =
                              data[index].measuringSec! ~/ 60 % 60;
                          num measuringSecondValue =
                              data[index].measuringSec! % 60;
                          //姿勢（不良）を時・分・秒に変換
                          num badHourValue =
                              data[index].measuringBadPostureSec! ~/ 60 ~/ 60;
                          num badMinuteValue =
                              data[index].measuringBadPostureSec! ~/ 60 % 60;
                          num badSecondValue =
                              data[index].measuringBadPostureSec! % 60;
                          //姿勢（良）を時・分・秒に変換
                          num goodHourValue = (data[index].measuringSec! -
                                  data[index].measuringBadPostureSec!) ~/
                              60 ~/
                              60;
                          num goodMinuteValue = (data[index].measuringSec! -
                                  data[index].measuringBadPostureSec!) ~/
                              60 %
                              60;
                          num goodSecondValue = (data[index].measuringSec! -
                                  data[index].measuringBadPostureSec!) %
                              60;
                          //カウント回数
                          num notificationCounter =
                              data[index].notificationCounter!;
                          //設定したカウンターの秒数
                          int timeToNotification =
                              data[index].timeToNotification!;

                          num measuringSec = data[index].measuringSec!;
                          num measuringGoodPostureSec =
                              (data[index].measuringSec! -
                                  data[index].measuringBadPostureSec!);
                          num measuringBadPostureSec =
                              data[index].measuringBadPostureSec!;
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
                                titleController.text = data[index].title!;
                                //下1行はtextFieldの入力内容の保存に関する意図しない処理を回避
                                model.title = data[index].title!.toString();

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
                                                color: Colors.green,
                                                height: 60,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      width: 70,
                                                      // color: Colors.red,
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
                                                        child: TextField(
                                                          onChanged: (text) {
                                                            model.title = text;
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
                                                                await model
                                                                    .fetchData();
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                primary: Colors
                                                                    .green,
                                                              ),
                                                              child:
                                                                  Text("保存")),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 30,
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
                                                        // color: Colors.white,

                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text("計測回数",
                                                                    style:
                                                                        style),
                                                                Text(
                                                                  "${data.length - index}回目",
                                                                  style: style,
                                                                ),
                                                              ],
                                                            ),
                                                            Divider(),
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
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text("計測時間",
                                                                    style:
                                                                        style),
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      measuringHourValue >
                                                                              0
                                                                          ? "$measuringHourValue時間"
                                                                          : "　",
                                                                      style:
                                                                          style,
                                                                    ),
                                                                    Text(
                                                                      measuringMinuteValue >
                                                                              0
                                                                          ? "$measuringMinuteValue分"
                                                                          : "",
                                                                      style:
                                                                          style,
                                                                    ),
                                                                    Text(
                                                                      measuringSecondValue >
                                                                              0
                                                                          ? "$measuringSecondValue秒"
                                                                          : "",
                                                                      style:
                                                                          style,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            Divider(),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Text("姿勢",
                                                                        style:
                                                                            style),
                                                                    Text("(良)",
                                                                        style:
                                                                            styleGreen),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      goodHourValue >
                                                                              0
                                                                          ? "$goodHourValue時間"
                                                                          : "　",
                                                                      style:
                                                                          styleGreen,
                                                                    ),
                                                                    Text(
                                                                      goodMinuteValue >
                                                                              0
                                                                          ? "$goodMinuteValue分"
                                                                          : "",
                                                                      style:
                                                                          styleGreen,
                                                                    ),
                                                                    Text(
                                                                      goodSecondValue == 0 &&
                                                                              measuringSec >= 60
                                                                          ? ""
                                                                          : "$goodSecondValue秒",
                                                                      style:
                                                                          styleGreen,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            Divider(),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Text("姿勢",
                                                                        style:
                                                                            style),
                                                                    Text("(不良)",
                                                                        style:
                                                                            styleRed),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      badHourValue >
                                                                              0
                                                                          ? "$badHourValue時間"
                                                                          : "　",
                                                                      style:
                                                                          styleRed,
                                                                    ),
                                                                    Text(
                                                                      badMinuteValue >
                                                                              0
                                                                          ? "$badMinuteValue分"
                                                                          : "",
                                                                      style:
                                                                          styleRed,
                                                                    ),
                                                                    Text(
                                                                      badSecondValue == 0 &&
                                                                              measuringBadPostureSec >= 60
                                                                          ? ""
                                                                          : "$badSecondValue秒",
                                                                      style:
                                                                          styleRed,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            Divider(),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  timeToNotification ~/
                                                                              60 >
                                                                          0
                                                                      ? "猫背通知回数（設定：${(timeToNotification / 60).floor()}分）"
                                                                      : "猫背通知回数（設定：$timeToNotification秒）",
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
                                                      InkWell(
                                                        // highlightColor: Colors.grey,
                                                        // splashColor: Colors.green,
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
                                                                        await model
                                                                            .fetchData();
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
                                                                                title: Text("データの削除に失敗しました。"),
                                                                                content: Text("通信環境の良いところで再度試してください"),
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
                                                              style: styleRed,
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
                              //履歴リスト
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "No.${data.length - index}",
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
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
                                        // style: TextStyle(
                                        //     fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          // color: Colors.grey[300],
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
                                                  Text(
                                                    measuringHourValue > 0
                                                        ? "$measuringHourValue時間"
                                                        : "",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  Text(
                                                    measuringMinuteValue > 0
                                                        ? "$measuringMinuteValue分"
                                                        : "",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  Text(
                                                    measuringSecondValue > 0
                                                        ? "$measuringSecondValue秒"
                                                        : "",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          // color: Colors.grey[200],
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
                                                      // color: Colors.grey
                                                    ),
                                                  ),
                                                  Text(
                                                    "(良)",
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors
                                                            .greenAccent
                                                            .shade700),
                                                  ),
                                                ],
                                              ),
                                              Wrap(
                                                children: [
                                                  Text(
                                                    goodHourValue > 0
                                                        ? "$goodHourValue時間"
                                                        : "",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors
                                                            .greenAccent
                                                            .shade700,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  Text(
                                                    goodMinuteValue > 0
                                                        ? "$goodMinuteValue分"
                                                        : "",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors
                                                            .greenAccent
                                                            .shade700,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  Text(
                                                    goodSecondValue == 0 &&
                                                            measuringSec >= 60
                                                        ? ""
                                                        : "$goodSecondValue秒",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors
                                                            .greenAccent
                                                            .shade700,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Expanded(
                                      //   child: Container(
                                      //     // color: Colors.grey[300],
                                      //     child: Column(
                                      //       crossAxisAlignment:
                                      //           CrossAxisAlignment.start,
                                      //       children: [
                                      //         Row(
                                      //           mainAxisAlignment:
                                      //               MainAxisAlignment.start,
                                      //           children: [
                                      //             Text(
                                      //               "姿勢",
                                      //               style: TextStyle(
                                      //                 fontSize: 11,
                                      //                 // color: Colors.grey
                                      //               ),
                                      //             ),
                                      //             Text(
                                      //               "(不良)",
                                      //               style: TextStyle(
                                      //                   fontSize: 11,
                                      //                   color: Colors.red),
                                      //             ),
                                      //           ],
                                      //         ),
                                      //         Text(
                                      //           badHour > 0
                                      //               ? "$badHour時間"
                                      //               : "　",
                                      //           style: TextStyle(
                                      //               fontSize: 14,
                                      //               color: Colors.red,
                                      //               fontWeight:
                                      //                   FontWeight.w600),
                                      //         ),
                                      //         Row(
                                      //           children: [
                                      //             Text(
                                      //               badMinute > 0
                                      //                   ? "$badMinute分"
                                      //                   : "",
                                      //               style: TextStyle(
                                      //                   fontSize: 14,
                                      //                   color: Colors.red,
                                      //                   fontWeight:
                                      //                       FontWeight.w600),
                                      //             ),
                                      //             Text(
                                      //               badSecond > 0
                                      //                   ? "$badSecond秒"
                                      //                   : "",
                                      //               style: TextStyle(
                                      //                   fontSize: 14,
                                      //                   color: Colors.red,
                                      //                   fontWeight:
                                      //                       FontWeight.w600),
                                      //             ),
                                      //           ],
                                      //         ),
                                      //       ],
                                      //     ),
                                      //   ),
                                      // ),
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
                                      "${data[index].title}",
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
