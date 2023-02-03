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
              title: Text(
                "履歴",
                style: TextStyle(color: Colors.green),
              ),
              backgroundColor: Colors.white,
            ),
            body: Consumer<HistoryModel>(builder: (context, model, child) {
              const style = TextStyle(fontSize: 17);
              const styleG = TextStyle(fontSize: 17, color: Colors.green);
              const styleR = TextStyle(fontSize: 17, color: Colors.red);
              final List<Data>? data = model.data;
              return Stack(
                children: [
                  Scrollbar(
                    child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: data!.length,
                        itemBuilder: (BuildContext context, int index) {
                          String createdAt = data[index].createdAt!;
                          num measuringMin = data[index].measuringMin!;
                          num measuringSec = data[index].measuringSec!;
                          num measuringGoodPostureMin =
                              data[index].measuringMin! -
                                  data[index].measuringBadPostureMin!;
                          num measuringGoodPostureSec =
                              data[index].measuringSec! -
                                  data[index].measuringBadPostureSec!;
                          num measuringBadPostureMin =
                              data[index].measuringBadPostureMin!;
                          num measuringBadPostureSec =
                              data[index].measuringBadPostureSec!;
                          num notificationCounter =
                              data[index].notificationCounter!;
                          int timeToNotification =
                              data[index].timeToNotification!;
                          return Container(
                            decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(width: 0.2))),
                            child: ListTile(
                              // tileColor: index.isOdd
                              //     ? Colors.transparent
                              //     : Colors.grey.withOpacity(0.1),
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
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    bottom:
                                                        BorderSide(width: 1),
                                                  ),
                                                ),
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
                                                          child:
                                                              Icon(Icons.close),
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                                  shape:
                                                                      CircleBorder(),
                                                                  primary: Colors
                                                                      .grey),
                                                        ),
                                                      ),
                                                    ),
                                                    Center(
                                                      child: Text(
                                                        "履歴詳細",
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 70,
                                                      // color: Colors.red,
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
                                                          "タイトル",
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
                                                              15,
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
                                                                await model
                                                                    .updateTitle(
                                                                        data[
                                                                            index]);
                                                                await model
                                                                    .fetchData();
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
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
                                                                Text(
                                                                    "$measuringMin分 "
                                                                    "(${measuringSec ~/ 60 >= 1 ? "${measuringSec ~/ 60}分"
                                                                        "${measuringSec % 60}秒" : "${measuringSec % 60}秒"})",
                                                                    style:
                                                                        style),
                                                                Text("〇〇時間"),
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
                                                                            styleG),
                                                                  ],
                                                                ),
                                                                Text(
                                                                    "${measuringGoodPostureMin.toStringAsFixed(1)}分 "
                                                                    "(${measuringGoodPostureSec ~/ 60 > 0 ? "${measuringGoodPostureSec ~/ 60}分"
                                                                        "${measuringGoodPostureSec % 60}秒" : "${measuringGoodPostureSec % 60}秒"})",
                                                                    style:
                                                                        styleG),
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
                                                                    Text("(不)",
                                                                        style:
                                                                            styleR),
                                                                  ],
                                                                ),
                                                                Text(
                                                                    "$measuringBadPostureMin分 "
                                                                    "(${measuringBadPostureSec ~/ 60 >= 1 ? "${measuringBadPostureSec ~/ 60}分"
                                                                        "${measuringBadPostureSec % 60}秒" : "${measuringBadPostureSec % 60}秒"})",
                                                                    style:
                                                                        styleR),
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
                                                                      ? "猫背通知カウンター（設定：${(timeToNotification / 60).floor()}分）"
                                                                      : "猫背通知カウンター（設定：$timeToNotification秒）",
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
                                                        height: 100,
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
                                                                    "計測データの合計平均値が変化\nしますがデータを削除しますか？"),
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
                                                                      await model
                                                                          .delete(
                                                                              data[index]);
                                                                      await model
                                                                          .fetchData();
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                      final snackBar =
                                                                          SnackBar(
                                                                        backgroundColor:
                                                                            Colors.red,
                                                                        content:
                                                                            Text("削除しました"),
                                                                      );
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                              snackBar);
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
                                                              style: styleR,
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
                                  Text(
                                    "No.${data.length - index}",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        createdAt.substring(0, 4) +
                                            "/ " +
                                            createdAt.substring(5, 7) +
                                            "/ " +
                                            createdAt.substring(8, 10),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        "${data[index].title}",
                                        style: TextStyle(
                                            fontSize: 13, color: Colors.grey),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    // mainAxisAlignment:
                                    //     MainAxisAlignment.spaceEvenly,
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
                                                  // color: Colors.grey
                                                ),
                                              ),
                                              Text(
                                                "${(measuringMin / 60).toStringAsFixed(2)}時間",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              //高さをそろえる役割
                                              // Text(
                                              //   "　",
                                              //   style: TextStyle(fontSize: 10),
                                              // ),
                                              // Text(
                                              //   "(8時間88分)",
                                              //   style: TextStyle(fontSize: 10),
                                              // ),
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
                                                        color: Colors.green),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                // "10.00時間",
                                                "${(measuringGoodPostureMin / 60).toStringAsFixed(2)}時間",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.green,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              //高さをそろえる役割
                                              // Text(
                                              //   "　",
                                              //   style: TextStyle(fontSize: 10),
                                              // ),
                                              // Text(
                                              //   measuringSec > 2
                                              //       ? "${((measuringGoodPostureMin / measuringMin) * 100).toStringAsFixed(1)}％"
                                              //       : "---％",
                                              //   style: TextStyle(
                                              //       color: Colors.green,
                                              //       fontSize: 10),
                                              // ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          // color: Colors.grey[300],
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
                                                    "(不)",
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.red),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                // "10.00時間",
                                                "${(measuringBadPostureMin / 60).toStringAsFixed(2)}時間",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.red,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              // Text(
                                              //   measuringSec > 2
                                              //       ? "${((measuringBadPostureMin / measuringMin) * 100).toStringAsFixed(1)}％"
                                              //       : "---％",
                                              //   style: TextStyle(
                                              //       color: Colors.red,
                                              //       fontSize: 10),
                                              // ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: SizedBox(),
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "姿勢",
                                                  style:
                                                      TextStyle(fontSize: 11),
                                                ),
                                                Text(
                                                  "(良)",
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.green),
                                                ),
                                                Text(
                                                  "率",
                                                  style:
                                                      TextStyle(fontSize: 11),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              measuringSec > 2
                                                  ? "${((measuringGoodPostureMin / measuringMin) * 100).toStringAsFixed(1)}％"
                                                  : "---％",
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  // SizedBox(
                                  //   height: 5,
                                  // ),
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
