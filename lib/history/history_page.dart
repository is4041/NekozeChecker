import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:posture_correction/history/history_model.dart';
import 'package:posture_correction/single_touch_container.dart';
import 'package:provider/provider.dart';

import '../data.dart';
import '../utils.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool _processing = false;
    var screenSize = MediaQuery.of(context).size;
    return ChangeNotifierProvider<HistoryModel>(
        create: (_) => HistoryModel()..fetchData(),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              elevation: 1,
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
                    child: SingleTouchContainer(
                      child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: data!.length,
                          itemBuilder: (BuildContext context, int index) {
                            //日付を取得
                            String _createdAt = data[index].createdAt!;

                            //グリーンラインの幅を取得
                            num _greenLineRange = data[index].greenLineRange!;
                            String _range = "";
                            if (_greenLineRange == 10) {
                              _range = "狭い";
                            } else if (_greenLineRange == 12.5) {
                              _range = "やや狭い";
                            } else if (_greenLineRange == 15) {
                              _range = "普通";
                            } else if (_greenLineRange == 17.5) {
                              _range = "やや広い";
                            } else if (_greenLineRange == 20) {
                              _range = "広い";
                            }

                            //計測時間を時・分・秒に変換
                            num _measuringSec = data[index].measuringSec!;
                            num _measuringHourValue = _measuringSec ~/ 60 ~/ 60;
                            num _measuringMinuteValue =
                                _measuringSec ~/ 60 % 60;
                            num _measuringSecondValue = _measuringSec % 60;

                            //姿勢（猫背）を時・分・秒に変換
                            num _measuringBadPostureSec =
                                data[index].measuringBadPostureSec!;
                            num _badHourValue =
                                _measuringBadPostureSec ~/ 60 ~/ 60;
                            num _badMinuteValue =
                                _measuringBadPostureSec ~/ 60 % 60;
                            num _badSecondValue = _measuringBadPostureSec % 60;

                            //姿勢（良）を時・分・秒に変換
                            num _measuringGoodPostureSec =
                                (_measuringSec - _measuringBadPostureSec);
                            num _goodHourValue =
                                _measuringGoodPostureSec ~/ 60 ~/ 60;
                            num _goodMinuteValue =
                                _measuringGoodPostureSec ~/ 60 % 60;
                            num _goodSecondValue =
                                _measuringGoodPostureSec % 60;

                            //警告音カウント回数
                            num _notificationCounter =
                                data[index].notificationCounter!;

                            //設定した警告音通知までの秒数
                            int _timeToNotification =
                                data[index].timeToNotification!;

                            //姿勢（良）の割合を取得
                            num _rateOfGoodPosture = double.parse(
                                ((_measuringGoodPostureSec / _measuringSec) *
                                        100)
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
                                                  color: Colors
                                                      .greenAccent.shade700,
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
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            style: ElevatedButton.styleFrom(
                                                                shape:
                                                                    CircleBorder(),
                                                                backgroundColor:
                                                                    Colors
                                                                        .white),
                                                          ),
                                                        ),
                                                      ),
                                                      Center(
                                                        child: Text(
                                                          "履歴詳細",
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 10),
                                                            child: Text(
                                                              "メモ",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black54),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
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
                                                                  EdgeInsets
                                                                      .only(
                                                                          top:
                                                                              5),
                                                              prefixIcon: Icon(
                                                                  Icons.edit),
                                                              border:
                                                                  InputBorder
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
                                                            child:
                                                                ElevatedButton(
                                                                    onPressed:
                                                                        () async {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                      await model
                                                                          .updateTitle(
                                                                              data[index]);
                                                                    },
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      backgroundColor: Colors
                                                                          .greenAccent
                                                                          .shade700,
                                                                    ),
                                                                    child: Text(
                                                                        "メモ保存")),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 30,
                                                        ),
                                                        Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 10),
                                                            child: Text(
                                                              "計測データ",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black54),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10.0),
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
                                                                    style:
                                                                        style,
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
                                                                      _createdAt.substring(
                                                                              0, 4) +
                                                                          "年" +
                                                                          _createdAt.substring(
                                                                              5,
                                                                              7) +
                                                                          "月" +
                                                                          _createdAt.substring(
                                                                              8,
                                                                              10) +
                                                                          "日",
                                                                      style:
                                                                          style),
                                                                ],
                                                              ),
                                                              Divider(),
                                                              //計測時間を表示
                                                              _TimeValue(
                                                                posture: "",
                                                                hourValue:
                                                                    _measuringHourValue,
                                                                minuteValue:
                                                                    _measuringMinuteValue,
                                                                secondValue:
                                                                    _measuringSecondValue,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              Divider(),
                                                              //計測時間（姿勢・良）を表示
                                                              _TimeValue(
                                                                posture:
                                                                    "（姿勢・良）",
                                                                hourValue:
                                                                    _goodHourValue,
                                                                minuteValue:
                                                                    _goodMinuteValue,
                                                                secondValue:
                                                                    _goodSecondValue,
                                                                color: Colors
                                                                    .greenAccent
                                                                    .shade700,
                                                              ),
                                                              Divider(),
                                                              //計測時間（姿勢・不良）を表示
                                                              _TimeValue(
                                                                posture:
                                                                    "（姿勢・猫背）",
                                                                hourValue:
                                                                    _badHourValue,
                                                                minuteValue:
                                                                    _badMinuteValue,
                                                                secondValue:
                                                                    _badSecondValue,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                              Divider(),
                                                              //警告音が鳴った回数を表示
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    "警告回数（設定：$_timeToNotification秒）",
                                                                    style:
                                                                        style,
                                                                  ),
                                                                  Text(
                                                                    "$_notificationCounter回",
                                                                    style:
                                                                        style,
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
                                                                    "グリーンラインの幅",
                                                                    style:
                                                                        style,
                                                                  ),
                                                                  Text(
                                                                    Utils.nekoMode ==
                                                                            true
                                                                        ? "${_range}ニャ"
                                                                        : _range,
                                                                    style:
                                                                        style,
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
                                                              barrierDismissible:
                                                                  false,
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return SingleTouchContainer(
                                                                  child: CupertinoAlertDialog(
                                                                      title: Text(
                                                                          "データ削除"),
                                                                      content: Text(
                                                                          "計測データの平均値が変化しますが\nデータを削除しますか？"),
                                                                      actions: [
                                                                        TextButton(
                                                                          child:
                                                                              const Text(
                                                                            "削除",
                                                                            style:
                                                                                TextStyle(color: Colors.red),
                                                                          ),
                                                                          onPressed:
                                                                              () async {
                                                                            if (_processing)
                                                                              return;
                                                                            _processing =
                                                                                true;
                                                                            try {
                                                                              await model.delete(data[index]);
                                                                              Navigator.of(context).pop();
                                                                              final snackBar = SnackBar(backgroundColor: Colors.red, content: Text("削除しました"));
                                                                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                                            } catch (e) {
                                                                              await showDialog(
                                                                                  barrierColor: Colors.transparent,
                                                                                  context: context,
                                                                                  builder: (BuildContext context) {
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
                                                                            Navigator.of(context).pop();
                                                                            _processing =
                                                                                false;
                                                                          },
                                                                        ),
                                                                        TextButton(
                                                                          child:
                                                                              Text("キャンセル"),
                                                                          onPressed:
                                                                              () {
                                                                            if (_processing)
                                                                              return;
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                        ),
                                                                      ]),
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
                                                              color:
                                                                  Colors.white,
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
                                                                    fontSize:
                                                                        17,
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
                                          _createdAt.substring(0, 4) +
                                              "/ " +
                                              _createdAt.substring(5, 7) +
                                              "/ " +
                                              _createdAt.substring(8, 10),
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
                                                  _TimeValue2(
                                                      time: _measuringHourValue,
                                                      timeUnit: "時間",
                                                      color: Colors.black),
                                                  _TimeValue2(
                                                      time:
                                                          _measuringMinuteValue,
                                                      timeUnit: "分",
                                                      color: Colors.black),
                                                  _TimeValue2(
                                                      time:
                                                          _measuringSecondValue,
                                                      timeUnit: "秒",
                                                      color: Colors.black),
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
                                                        color: Colors
                                                            .greenAccent
                                                            .shade700),
                                                  ),
                                                ],
                                              ),
                                              Wrap(
                                                children: [
                                                  _TimeValue2(
                                                      time: _goodHourValue,
                                                      timeUnit: "時間",
                                                      color: Colors.greenAccent
                                                          .shade700),
                                                  _TimeValue2(
                                                      time: _goodMinuteValue,
                                                      timeUnit: "分",
                                                      color: Colors.greenAccent
                                                          .shade700),
                                                  _TimeValue2(
                                                      time: _goodSecondValue,
                                                      timeUnit: "秒",
                                                      color: Colors.greenAccent
                                                          .shade700),
                                                  //無表示を防ぐ
                                                  Visibility(
                                                    visible:
                                                        _measuringGoodPostureSec ==
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
                                                        color: Colors
                                                            .greenAccent
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
                                                "$_rateOfGoodPosture％",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: _rateOfGoodPosture >=
                                                            90
                                                        //90%以上
                                                        ? Colors.greenAccent
                                                            .shade700
                                                        : _rateOfGoodPosture >=
                                                                80
                                                            //80%以上
                                                            ? Color(0xFF2BD600)
                                                            : _rateOfGoodPosture >=
                                                                    70
                                                                //70%以上
                                                                ? Color(
                                                                    0xFF58DB00)
                                                                : _rateOfGoodPosture >=
                                                                        60
                                                                    //60%以上
                                                                    ? Color(
                                                                        0xFF88E200)
                                                                    : _rateOfGoodPosture >=
                                                                            50
                                                                        //50%以上
                                                                        ? Color(
                                                                            0xFFBFE600)
                                                                        : _rateOfGoodPosture >=
                                                                                40
                                                                            //40%以上
                                                                            ? Color(0xFFEBDB00)
                                                                            : _rateOfGoodPosture >= 30
                                                                                //30%以上
                                                                                ? Color(0xFFF0A800)
                                                                                : _rateOfGoodPosture >= 20
                                                                                    //20%以上
                                                                                    ? Color(0xFFF57200)
                                                                                    : _rateOfGoodPosture >= 10
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
class _TimeValue extends StatelessWidget {
  _TimeValue({
    required this.posture,
    required this.hourValue,
    required this.minuteValue,
    required this.secondValue,
    required this.color,
  });
  final String posture;
  final num hourValue;
  final num minuteValue;
  final num secondValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("計測時間${(posture)}", style: TextStyle(fontSize: 17, color: color)),
        Row(
          children: [
            Text(hourValue > 0 ? "$hourValue時間" : "",
                style: TextStyle(fontSize: 17, color: color)),
            Text(minuteValue > 0 ? "$minuteValue分" : "",
                style: TextStyle(fontSize: 17, color: color)),
            Text(
              secondValue > 0 ? "$secondValue秒" : "",
              style: TextStyle(fontSize: 17, color: color),
            ),
            Visibility(
              visible: hourValue == 0 && minuteValue == 0 && secondValue == 0,
              child: Text("0秒", style: TextStyle(fontSize: 17, color: color)),
            ),
          ],
        ),
      ],
    );
  }
}

//履歴の時間の表示
class _TimeValue2 extends StatelessWidget {
  _TimeValue2({
    required this.time,
    required this.timeUnit,
    required this.color,
  });
  final num time;
  final String timeUnit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      time > 0 ? "$time$timeUnit" : "",
      style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w600),
    );
  }
}
