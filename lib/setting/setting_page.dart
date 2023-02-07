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
              elevation: 0,
              // shadowColor: Colors.green,
              backgroundColor: Colors.grey[100],
              title: Text(
                "設  定",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent.shade700),
              ),
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
                      child: Utils.isAnonymous == "isAnonymous"
                          ? InkWell(
                              highlightColor: Colors.grey[400],
                              onTap: () async {
                                try {
                                  await model.googleSignIn();
                                  await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CupertinoAlertDialog(
                                          title: Text("アカウント提携が完了しました"),
                                          actions: [
                                            TextButton(
                                              child: const Text("OK"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            )
                                          ],
                                        );
                                      });
                                } catch (e) {
                                  if (e.toString() ==
                                      "[firebase_auth/credential-already-in-use] This credential is already associated with a different user account.") {
                                    await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CupertinoAlertDialog(
                                            //todo 文章を考える
                                            title: Text("エラー"),
                                            content: Text(
                                                "このアカウントはすでに別のユーザーアカウントに関連付けられています。"),
                                            actions: [
                                              TextButton(
                                                child: const Text("OK"),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              )
                                            ],
                                          );
                                        });
                                  } else if (e.toString() !=
                                      "Null check operator used on a null value") {
                                    await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CupertinoAlertDialog(
                                            title: Text(
                                                "アカウントの連携に失敗しました。通信環境の良いところで再度試してください。"),
                                            actions: [
                                              TextButton(
                                                child: const Text("OK"),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              )
                                            ],
                                          );
                                        });
                                  }
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Googleアカウント提携",
                                    style: TextStyle(fontSize: 17),
                                  ),
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  Utils.isAnonymous == "isNotAnonymous"
                                      ? "Googleアカウント提携済"
                                      : "Googleアカウント提携",
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.grey),
                                ),
                              ),
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
                                              try {
                                                await model
                                                    .upDateTimeToNotification();
                                                await model.searchListIndex();
                                              } catch (e) {
                                                await showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return CupertinoAlertDialog(
                                                        title: Text(
                                                            "保存に失敗しました。通信環境の良いところで再度試してください。"),
                                                        actions: [
                                                          TextButton(
                                                            child: const Text(
                                                                "OK"),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          )
                                                        ],
                                                      );
                                                    });
                                              }
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
                      child: Utils.isAnonymous == "isNotAnonymous"
                          ? InkWell(
                              highlightColor: Colors.grey[400],
                              onTap: () async {
                                await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CupertinoAlertDialog(
                                        title: Text("ログアウトしますか？"),
                                        actions: [
                                          TextButton(
                                            child: Text("OK"),
                                            onPressed: () async {
                                              try {
                                                await model.logout();
                                              } catch (e) {
                                                await showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return CupertinoAlertDialog(
                                                        title: Text(
                                                            "ログアウトに失敗しました。通信環境の良いところで再度試してください。"),
                                                        actions: [
                                                          TextButton(
                                                            child: const Text(
                                                                "OK"),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          )
                                                        ],
                                                      );
                                                    });
                                              }
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text("キャンセル"),
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
                                return CupertinoAlertDialog(
                                  title: Text("全データ削除（初期化）"),
                                  content: Text("全てのデータが削除されます。"),
                                  actions: [
                                    TextButton(
                                      child: Text(
                                        "削除",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onPressed: () async {
                                        await showDialog(
                                            barrierColor: Colors.transparent,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return CupertinoAlertDialog(
                                                title: Text("再確認"),
                                                content: Text("本当に削除しますか？"),
                                                actions: [
                                                  TextButton(
                                                    child: Text(
                                                      "削除",
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                    onPressed: () async {
                                                      try {
                                                        await model
                                                            .deleteUser();
                                                      } catch (e) {
                                                        await showDialog(
                                                            barrierColor: Colors
                                                                .transparent,
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return CupertinoAlertDialog(
                                                                title: Text(
                                                                    "データの削除に失敗しました。"),
                                                                content: Text(
                                                                    "通信環境の良いところで再度試してください"),
                                                                actions: [
                                                                  TextButton(
                                                                    child: Text(
                                                                      "OK",
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  ),
                                                                ],
                                                              );
                                                            });
                                                      }
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text("キャンセル"),
                                                    onPressed: () async {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  )
                                                ],
                                              );
                                            });

                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text("キャンセル"),
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
                            "全データ削除（初期化）",
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
