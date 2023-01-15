import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:posture_correction/setting/setting_model.dart';
import 'package:posture_correction/setting/setting_model.dart';
import 'package:posture_correction/signin/signin_page.dart';
import 'package:posture_correction/utils.dart';
import 'package:provider/provider.dart';

final auth = FirebaseAuth.instance;

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SettingModel>(
        create: (_) => SettingModel()..searchListIndex(),
        builder: (context, snapshot) {
          return Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              title: Text(
                "設定",
                style: TextStyle(color: Colors.green),
              ),
              backgroundColor: Colors.white,
            ),
            body: Consumer<SettingModel>(builder: (context, model, child) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "アカウント提携",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ),
                    Ink(
                      decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey, width: 0.5),
                            bottom: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                          color: Colors.white),
                      height: 45,
                      width: double.infinity,
                      //todo
                      child: Utils.providerId != "google.com"
                          ? InkWell(
                              highlightColor: Colors.grey[400],
                              onTap: () async {
                                try {
                                  await model.googleSignIn();
                                  await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("アカウント提携が完了しました"),
                                          actions: [
                                            TextButton(
                                              child: const Text("ok"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            )
                                          ],
                                        );
                                      });
                                } catch (e) {
                                  await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(e.toString()),
                                          actions: [
                                            TextButton(
                                              child: const Text("ok"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            )
                                          ],
                                        );
                                      });
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Googleアカウント提携",
                                      style: TextStyle(fontSize: 17),
                                    )),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Googleアカウント提携済",
                                    style: TextStyle(
                                        fontSize: 17, color: Colors.grey),
                                  )),
                            ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "猫背を通知するまでの時間",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showCupertinoModalPopup(
                            context: context,
                            builder: (context) {
                              return Container(
                                height: 250,
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CupertinoButton(
                                            child: const Text("保存️",
                                                style: TextStyle(fontSize: 20)),
                                            onPressed: () async {
                                              await model
                                                  .upDateTimeToNotification();
                                              await model.searchListIndex();
                                              Navigator.pop(context);
                                            }),
                                        CupertinoButton(
                                            child: Text(
                                              "×️",
                                              style: TextStyle(
                                                  fontSize: 30,
                                                  color: Colors.red),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            }),
                                      ],
                                    ),
                                    // SizedBox(
                                    //   height: 30,
                                    // ),
                                    Divider(
                                      thickness: 1,
                                    ),
                                    Expanded(
                                      child: CupertinoPicker(
                                        onSelectedItemChanged: (int index) {
                                          Utils.timeToNotification =
                                              model.secondsList[index];
                                        },
                                        scrollController:
                                            FixedExtentScrollController(
                                                initialItem:
                                                    model.secondsListIndex),
                                        itemExtent: 40,
                                        children: model.secondsList
                                            .map((seconds) => Center(
                                                child: Text(seconds ~/ 60 > 0
                                                    ? "${(seconds / 60).toInt()} 分"
                                                    : "${seconds} 秒")))
                                            .toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            });
                      },
                      child: Container(
                        height: 45,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey, width: 0.5),
                              bottom:
                                  BorderSide(color: Colors.grey, width: 0.5),
                            ),
                            color: Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                Utils.timeToNotification ~/ 60 > 0
                                    ? "${(Utils.timeToNotification / 60).toInt()} 分"
                                    : "${Utils.timeToNotification} 秒",
                                style: TextStyle(fontSize: 17),
                              )),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "ユーザーID",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ),
                    Container(
                      height: 45,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey, width: 0.5),
                            bottom: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                          color: Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Utils.userId,
                              style:
                                  TextStyle(fontSize: 17, color: Colors.grey),
                            )),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "ログアウト",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ),
                    Ink(
                      decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey, width: 0.5),
                            bottom: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                          color: Colors.white),
                      height: 45,
                      width: double.infinity,
                      child: Utils.providerId == "google.com"
                          ? InkWell(
                              highlightColor: Colors.grey[400],
                              onTap: () async {
                                await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("ログアウトしますか？"),
                                        actions: [
                                          TextButton(
                                            child: Text("はい"),
                                            onPressed: () async {
                                              await model.logout();
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text("いいえ"),
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                            },
                                          )
                                        ],
                                      );
                                    });
                              },
                              child: const Center(
                                child: Text(
                                  "ログアウト",
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                "ログアウト",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "データ削除",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ),
                    Ink(
                      decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey, width: 0.5),
                            bottom: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                          color: Colors.white),
                      height: 45,
                      width: double.infinity,
                      child: InkWell(
                        highlightColor: Colors.grey[400],
                        onTap: () async {
                          await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("データを削除しますか？"),
                                  actions: [
                                    TextButton(
                                      child: Text("はい"),
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text("いいえ"),
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                );
                              });
                        },
                        child: const Center(
                          child: Text(
                            "全データ削除",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        });
  }
}
