import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:posture_correction/setting/setting_model.dart';
import 'package:posture_correction/single_touch_container.dart';
import 'package:posture_correction/utils.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool _processing = false;
    return ChangeNotifierProvider<SettingModel>(
        create: (_) => SettingModel()..searchListIndex(),
        builder: (context, snapshot) {
          return Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              elevation: 1,
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
                    //緑線の間隔の設定
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "ネコモード",
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ),
                    Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey, width: 0.5),
                            bottom: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                          color: Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "ネコモード",
                              style: TextStyle(fontSize: 17),
                            ),
                            Switch(
                                activeColor: Colors.greenAccent.shade700,
                                value: Utils.nekoMode,
                                onChanged: (bool? value) async {
                                  if (value != null) {
                                    Utils.nekoMode = value;
                                    await model.isOnNekoMode();
                                    print(Utils.nekoMode);
                                  }
                                }),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "※ネコモードをオンにすると警告音がネコの鳴き声になります。その他、申し訳程度にネコ要素が追加されますのでどうぞ探してみてください。",
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "警告音が鳴るまでの時間",
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ),
                    //警告音が鳴るまでの秒数設定
                    InkWell(
                      onTap: () {
                        showCupertinoModalPopup(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return Container(
                                height: 250,
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    SingleTouchContainer(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          CupertinoButton(
                                              child: const Text("保存️",
                                                  style:
                                                      TextStyle(fontSize: 20)),
                                              onPressed: () async {
                                                if (_processing) return;
                                                _processing = true;
                                                try {
                                                  await model
                                                      .upDateTimeToNotification();
                                                } catch (e) {
                                                  await showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return CupertinoAlertDialog(
                                                          title: Text("エラー"),
                                                          content: Text(
                                                              "通信状態をご確認ください"),
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
                                                _processing = false;
                                              }),
                                          CupertinoButton(
                                              child: Text(
                                                "閉じる",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.red),
                                              ),
                                              onPressed: () {
                                                if (_processing) return;
                                                Navigator.pop(context);
                                              }),
                                        ],
                                      ),
                                    ),
                                    Divider(
                                      thickness: 1,
                                    ),
                                    //ドラムロール
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
                                                child: Text("${seconds} 秒")))
                                            .toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            });
                      },
                      //設定秒数を表示
                      child: Container(
                        height: 50,
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
                              "${Utils.timeToNotification} 秒",
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    //緑線の間隔の設定
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "グリーンラインの間隔",
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ),
                    //スライダーで範囲を調整
                    Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey, width: 0.5),
                            bottom: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                          color: Colors.white),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 36,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                        color: Colors.greenAccent.shade700,
                                        width: 2),
                                    bottom: BorderSide(
                                        color: Colors.greenAccent.shade700,
                                        width: 2),
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.arrow_upward,
                                        size: 16,
                                      ),
                                      Icon(
                                        Icons.arrow_downward,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 10,
                              child: Slider(
                                activeColor: Colors.greenAccent.shade700,
                                inactiveColor: Colors.grey.withOpacity(0.3),
                                value: Utils.greenLineRange,
                                max: 0.47,
                                min: 0.43,
                                divisions: 4,
                                onChanged: (double value) {
                                  Utils.greenLineRange =
                                      double.parse(value.toStringAsFixed(2));
                                  model.changeGreenLineRange();
                                },
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 50,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.arrow_downward,
                                        size: 16,
                                      ),
                                      Container(
                                        height: 14,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(
                                                color:
                                                    Colors.greenAccent.shade700,
                                                width: 2),
                                            bottom: BorderSide(
                                                color:
                                                    Colors.greenAccent.shade700,
                                                width: 2),
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_upward,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "アカウント提携",
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ),
                    //googleアカウント提携ボタン（匿名ログイン時のみ押下可）
                    Ink(
                      decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey, width: 0.5),
                            bottom: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                          color: Colors.white),
                      height: 50,
                      width: double.infinity,
                      //匿名ログイン時
                      child: Utils.isAnonymous == true
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
                                            title: Text("エラー"),
                                            content: Text(
                                                "このアカウントはすでに別のユーザーアカウントに関連付けられています。\n今お使いの端末でこのアカウントに提携するためには全データ削除（初期化）を行った後SignInWithGoogleボタンから提携してください"),
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
                                    print(e.toString());
                                    await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CupertinoAlertDialog(
                                            title: Text("エラー"),
                                            content: Text(e.toString()),
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
                              child: Center(
                                child: Text(
                                  "Googleアカウント提携",
                                  style: TextStyle(fontSize: 17),
                                ),
                              ),
                            )
                          //googleログイン時
                          : Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  Utils.isAnonymous == false
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
                        "ログアウト",
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ),
                    //ログアウトボタン（googleログイン時のみ押下可）
                    Ink(
                      decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey, width: 0.5),
                            bottom: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                          color: Colors.white),
                      height: 50,
                      width: double.infinity,
                      //googleログイン時
                      child: Utils.isAnonymous == false &&
                              Utils.userId.isNotEmpty
                          ? InkWell(
                              highlightColor: Colors.grey[400],
                              onTap: () async {
                                await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return SingleTouchContainer(
                                        child: CupertinoAlertDialog(
                                          title: Text("ログアウトしますか？"),
                                          actions: [
                                            TextButton(
                                              child: Text("はい"),
                                              onPressed: () async {
                                                if (_processing) return;
                                                _processing = true;
                                                try {
                                                  await model.logout();
                                                } catch (e) {
                                                  await showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return CupertinoAlertDialog(
                                                          title: Text("エラー"),
                                                          content: Text(
                                                              e.toString()),
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
                                                _processing = false;
                                              },
                                            ),
                                            TextButton(
                                              child: Text("キャンセル"),
                                              onPressed: () async {
                                                if (_processing) return;
                                                Navigator.of(context).pop();
                                              },
                                            )
                                          ],
                                        ),
                                      );
                                    });
                              },
                              child: const Center(
                                child: Text(
                                  "ログアウト",
                                ),
                              ),
                            )
                          //匿名ログイン時
                          : Center(
                              child: Text(
                                "ログアウト",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                    ),
                    SizedBox(
                      height: 250,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "データ削除",
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ),
                    //全データ消去（初期化）ボタン
                    Ink(
                      decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey, width: 0.5),
                            bottom: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                          color: Colors.white),
                      height: 50,
                      width: double.infinity,
                      child: InkWell(
                        highlightColor: Colors.grey[400],
                        onTap: () async {
                          await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SingleTouchContainer(
                                  child: CupertinoAlertDialog(
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
                                                return SingleTouchContainer(
                                                  child: CupertinoAlertDialog(
                                                    title: Text("再確認"),
                                                    content: Text("本当に削除しますか？"),
                                                    actions: [
                                                      TextButton(
                                                        child: Text(
                                                          "削除",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                        onPressed: () async {
                                                          if (_processing)
                                                            return;
                                                          _processing = true;
                                                          try {
                                                            await model
                                                                .deleteUser();
                                                          } catch (e) {
                                                            await showDialog(
                                                                barrierColor: Colors
                                                                    .transparent,
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return CupertinoAlertDialog(
                                                                    title: Text(
                                                                        "エラー"),
                                                                    content: Text(
                                                                        e.toString()),
                                                                    actions: [
                                                                      TextButton(
                                                                        child:
                                                                            Text(
                                                                          "OK",
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                      ),
                                                                    ],
                                                                  );
                                                                });
                                                          }

                                                          Navigator.of(context)
                                                              .pop();
                                                          _processing = false;
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: Text("キャンセル"),
                                                        onPressed: () async {
                                                          if (_processing)
                                                            return;
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      )
                                                    ],
                                                  ),
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
                                  ),
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
                    SizedBox(
                      height: 50,
                    ),
                  ],
                ),
              );
            }),
          );
        });
  }
}
