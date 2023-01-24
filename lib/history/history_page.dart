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
                          return ListTile(
                            tileColor: index.isOdd
                                ? Colors.transparent
                                : Colors.grey.withOpacity(0.1),
                            onTap: () {
                              TextEditingController titleController =
                                  TextEditingController();
                              titleController.text = data[index].title!;
                              //下1行はtextfieldの入力内容の保存に関する意図しない処理を回避
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
                                                  bottom: BorderSide(width: 1),
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
                                                          Navigator.of(context)
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
                                                              FontWeight.bold),
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
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        "タイトル",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey),
                                                      ),
                                                    ),
                                                    Container(
                                                      height: 40,
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
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
                                                          prefixIcon:
                                                              Icon(Icons.edit),
                                                          border:
                                                              InputBorder.none,
                                                        ),
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,
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
                                                              primary:
                                                                  Colors.green,
                                                            ),
                                                            child: Text("保存")),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 30,
                                                    ),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(10.0),
                                                      decoration: BoxDecoration(
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
                                                              Text("回数",
                                                                  style: style),
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
                                                                  style: style),
                                                              Text(
                                                                  data[index]
                                                                          .createdAt
                                                                          .toString()
                                                                          .substring(
                                                                              0,
                                                                              4) +
                                                                      "年" +
                                                                      data[index]
                                                                          .createdAt
                                                                          .toString()
                                                                          .substring(
                                                                              5,
                                                                              7) +
                                                                      "月" +
                                                                      data[index]
                                                                          .createdAt
                                                                          .toString()
                                                                          .substring(
                                                                              8,
                                                                              10) +
                                                                      "日",
                                                                  style: style),
                                                            ],
                                                          ),
                                                          Divider(),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text("計測時間",
                                                                  style: style),
                                                              Text(
                                                                  "${data[index].measuringMin}分 (${int.parse(data[index].measuringSec.toString()) ~/ 60 >= 1 ? "${int.parse(data[index].measuringSec.toString()) ~/ 60}分${int.parse(data[index].measuringSec.toString()) % 60}秒" : "${int.parse(data[index].measuringSec.toString()) % 60}秒"})",
                                                                  style: style),
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
                                                                  "${(double.parse(data[index].measuringMin.toString()) - double.parse(data[index].measuringBadPostureMin.toString())).toStringAsFixed(1)}分 (${(int.parse(data[index].measuringSec.toString()) - int.parse(data[index].measuringBadPostureSec.toString())) ~/ 60 > 0 ? "${(int.parse(data[index].measuringSec.toString()) - int.parse(data[index].measuringBadPostureSec.toString())) ~/ 60}分${(int.parse(data[index].measuringSec.toString()) - int.parse(data[index].measuringBadPostureSec.toString())) % 60}秒" : "${(int.parse(data[index].measuringSec.toString()) - int.parse(data[index].measuringBadPostureSec.toString())) % 60}秒"})",
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
                                                                  "${data[index].measuringBadPostureMin}分 (${int.parse(data[index].measuringBadPostureSec.toString()) ~/ 60 >= 1 ? "${int.parse(data[index].measuringBadPostureSec.toString()) ~/ 60}分${int.parse(data[index].measuringBadPostureSec.toString()) % 60}秒" : "${int.parse(data[index].measuringBadPostureSec.toString()) % 60}秒"})",
                                                                  style:
                                                                      styleR),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 150,
                                                    ),
                                                    InkWell(
                                                      // highlightColor: Colors.grey,
                                                      // splashColor: Colors.green,
                                                      onTap: () async {
                                                        await showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return CupertinoAlertDialog(
                                                              title:
                                                                  Text("データ削除"),
                                                              content: Text(
                                                                  "合計平均値が変化しますがデータを\n削除しますか？"),
                                                              actions: [
                                                                TextButton(
                                                                  child:
                                                                      const Text(
                                                                    "削除",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .red),
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
                                                                          Colors
                                                                              .red,
                                                                      content: Text(
                                                                          "削除しました"),
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
                                                        child: Center(
                                                          child: Text(
                                                            "データ削除",
                                                            style: styleR,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
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
                                Text("No.${data.length - index}"),
                                Row(
                                  children: [
                                    Text(
                                      data[index]
                                              .createdAt
                                              .toString()
                                              .substring(0, 4) +
                                          "/ " +
                                          data[index]
                                              .createdAt
                                              .toString()
                                              .substring(5, 7) +
                                          "/ " +
                                          data[index]
                                              .createdAt
                                              .toString()
                                              .substring(8, 10),
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
                                  children: [
                                    Expanded(
                                      child: Container(
                                        // color: Colors.grey[300],
                                        child: Column(
                                          children: [
                                            Text(
                                              "計測時間",
                                              style: TextStyle(fontSize: 13),
                                            ),
                                            Text(
                                              "${data[index].measuringMin}分",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),

                                            // Text(
                                            //   int.parse(data[index]
                                            //                   .measuringSec
                                            //                   .toString()) ~/
                                            //               60 >
                                            //           0
                                            //       ? "${int.parse(data[index].measuringSec.toString()) ~/ 60}分${int.parse(data[index].measuringSec.toString()) % 60}秒"
                                            //       : "${int.parse(data[index].measuringSec.toString()) % 60}秒",
                                            // ),
                                            SizedBox(
                                              height: 17.5,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        // color: Colors.grey[200],
                                        child: Column(
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
                                                      color: Colors.green),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              "${(double.parse(data[index].measuringMin.toString()) - double.parse(data[index].measuringBadPostureMin.toString())).toStringAsFixed(1)}分",
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              double.parse(data[index]
                                                          .measuringSec
                                                          .toString()) >
                                                      2
                                                  ? "${(((double.parse(data[index].measuringMin.toString()) - double.parse(data[index].measuringBadPostureMin.toString())) / (double.parse(data[index].measuringMin.toString()))) * 100).toStringAsFixed(1)}％"
                                                  : "---％",
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        // color: Colors.grey[300],
                                        child: Column(
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
                                                  "(不)",
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.red),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              "${data[index].measuringBadPostureMin}分",
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              double.parse(data[index]
                                                          .measuringSec
                                                          .toString()) >
                                                      2
                                                  ? "${((double.parse(data[index].measuringBadPostureMin.toString()) / double.parse(data[index].measuringMin.toString())) * 100).toStringAsFixed(1)}％"
                                                  : "---％",
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Expanded(
                                    //   child: Container(
                                    //     color: Colors.grey[200],
                                    //     child:
                                    //         Text("No.${data.length - index}"),
                                    //   ),
                                    // ),
                                  ],
                                ),
                                // Text("通知回数：${data.numberOfNotifications}回"),
                              ],
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
