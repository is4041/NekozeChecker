import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:posture_correction/signin/signin_model.dart';
import 'package:posture_correction/single_touch_container.dart';
import 'package:posture_correction/utils.dart';
import 'package:provider/provider.dart';
import 'package:sign_button/sign_button.dart';
import 'package:transparent_image/transparent_image.dart';

import '../bottomnavigation.dart';
import '../camera/camera_page.dart';

//おためしモードがtrueでfirebaseの処理を避ける
bool tryOutMode = false;

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double size =
        screenWidth < screenHeight / 2 ? screenWidth : screenHeight / 2;
    return ChangeNotifierProvider<SignInModel>(
        create: (_) => SignInModel(),
        builder: (context, snapshot) {
          return Scaffold(
            body: Consumer<SignInModel>(builder: (context, model, child) {
              final PageController pageController =
                  PageController(initialPage: 0);

              //ログアウト時チュートリアルページ非表示（ログアウト後アプリ再起動時は表示）
              final List<Widget> pages = Utils.showTutorial == true
                  ? [
                      _PageOne(size),
                      _PageTwo(size),
                      _PageThree(size),
                      _PageFour(size),
                      _PageFive(size),
                      _PageSix(model, size),
                    ]
                  : [
                      _PageSix(model, size),
                    ];
              return Stack(children: [
                StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return BottomNavigation();
                      }
                      return Stack(
                        children: [
                          PageView.builder(
                            controller: pageController,
                            onPageChanged: (int page) {
                              model.activePage = page;
                              model.active();
                            },
                            itemCount: pages.length,
                            itemBuilder: (BuildContext context, int index) {
                              return pages[index % pages.length];
                            },
                          ),
                          //ログアウト時非表示（ログアウト後アプリ再起動時は表示）
                          Visibility(
                            visible: Utils.showTutorial == true,
                            child: Positioned(
                              height: size * 0.3,
                              right: 0,
                              bottom: 0,
                              left: 0,
                              child: Column(
                                children: [
                                  //ページインジケータ
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List<Widget>.generate(
                                          pages.length,
                                          (index) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0),
                                            child: CircleAvatar(
                                              radius: 5,
                                              backgroundColor:
                                                  model.activePage == index
                                                      ? Colors
                                                          .greenAccent.shade700
                                                      : Colors.grey.shade300,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  //次へボタン
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    child: Container(
                                      height: 40,
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: model.activePage < 5
                                            ? () {
                                                pageController.nextPage(
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    curve: Curves.ease);
                                              }
                                            : () {},
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: model.activePage <
                                                    5
                                                ? Colors.greenAccent.shade700
                                                : Colors.grey,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            )),
                                        child: Text(
                                          "次へ",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                //ローディング中インジケータ表示
                if (model.isLoading)
                  Container(
                    color: Colors.grey.withOpacity(0.7),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
              ]);
            }),
          );
        });
  }
}

//1ページ目
class _PageOne extends StatelessWidget {
  _PageOne(this.size);

  final size;

  @override
  Widget build(BuildContext context) {
    return _PageContents(
      size: size,
      image: "images/IMG_0196.JPG",
      title: "ねこぜチェッカーへようこそ",
      description: Column(
        children: [
          Text(
            "ねこぜチェッカーはゲームやデスクワーク中の猫背や居眠りを検知すると警告音でお知らせするアプリです。",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}

//2ページ目
class _PageTwo extends StatelessWidget {
  _PageTwo(this.size);

  final size;

  @override
  Widget build(BuildContext context) {
    return _PageContents(
      size: size,
      image: "images/IMG_0345.JPG",
      title: "スマートフォンをセットする",
      description: Column(
        children: [
          Text(
            "上の画像のようにスマートフォンをセットし、STARTボタンを押してカメラを起動します。",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "◎カメラに顔が映る範囲であればどこにセットしても大丈夫ですが緑の点線内がより正確に猫背を検知できます。",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

//3ページ目
class _PageThree extends StatelessWidget {
  _PageThree(this.size);

  final size;

  @override
  Widget build(BuildContext context) {
    return _PageContents(
      size: size,
      image: "images/IMG_Unsplash.jpg",
      title: "カメラに顔が映るようにする",
      description: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text:
                TextSpan(style: DefaultTextStyle.of(context).style, children: [
              TextSpan(
                  text: "1. ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextSpan(text: "姿勢を正します。", style: TextStyle(fontSize: 16)),
              TextSpan(
                  text: "（白点とグリーンラインは鼻の位置と連動し、自動調整されます。）",
                  style: TextStyle(
                    fontSize: 12,
                  )),
            ]),
          ),
          SizedBox(height: 10),
          RichText(
            text:
                TextSpan(style: DefaultTextStyle.of(context).style, children: [
              TextSpan(
                  text: "2. ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextSpan(
                  text: "開始ボタン押下で計測スタート！白点がグリーンラインの間から出ないように姿勢を保ち続けましょう。",
                  style: TextStyle(fontSize: 16)),
            ]),
          ),
        ],
      ),
    );
  }
}

//4ページ目
class _PageFour extends StatelessWidget {
  _PageFour(this.screenSize);

  final screenSize;
  @override
  Widget build(BuildContext context) {
    return _PageContents(
      size: screenSize,
      image: "images/IMG_0310.JPG",
      title: "白点とラインカラーの関係",
      description: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
              text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                TextSpan(
                    text: "黄色",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow)),
                TextSpan(
                    text: "・・・猫背とは判定されませんが警告音はなります。",
                    style: TextStyle(fontSize: 16)),
              ])),
          SizedBox(
            height: 10,
          ),
          RichText(
              text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                TextSpan(
                    text: "緑色",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent.shade700)),
                TextSpan(text: "・・・姿勢良好です。", style: TextStyle(fontSize: 16)),
              ])),
          SizedBox(
            height: 10,
          ),
          RichText(
              text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                TextSpan(
                    text: "赤色",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent)),
                TextSpan(
                    text: "・・・猫背です。警告音がなります。", style: TextStyle(fontSize: 16)),
              ])),
        ],
      ),
    );
  }
}

//5ページ目
class _PageFive extends StatelessWidget {
  _PageFive(this.screenSize);

  final screenSize;

  @override
  Widget build(BuildContext context) {
    return _PageContents(
      size: screenSize,
      image: "images/IMG_0343.JPG",
      title: " 使わなくなった端末を活用できます ",
      description: Column(
        children: [
          Text(
            "GoogleやAppleでサインインすると複数の端末の間でデータの同期ができます。",
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "同期をすることで今お使いの端末をデータ閲覧用、使わなくなった端末をカメラ計測用にするということもできます。",
            style: TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}

//6ページ目
class _PageSix extends StatelessWidget {
  _PageSix(this.model, this.size);

  final SignInModel model;
  final size;

  @override
  Widget build(BuildContext context) {
    return SingleTouchContainer(
      child: Stack(
        children: [
          SizedBox(
            height: size,
            width: double.infinity,
            child: Opacity(
              opacity: 0.8,
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image:
                    "https://images.unsplash.com/photo-1547960450-2ea08b931270?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2832&q=80",
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
              height: size,
              width: double.infinity,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "ねこぜ",
                      style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent.shade700),
                    ),
                    Text(
                      "ちぇっかー",
                      style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[50]),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment(0, 0.5),
            child: FittedBox(
              child: Container(
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                      width: 240,
                      child: ElevatedButton(
                        onPressed: () async {
                          await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SingleTouchContainer(
                                  child: CupertinoAlertDialog(
                                    title: Text("おためしモード"),
                                    content: Column(
                                      children: [
                                        Text(
                                            "おためしモードではデータは保存されません。\nGoogleやAppleでサインインすることでデータの永続化、グラフの閲覧、その他詳細な設定ができるようになります。"),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text(
                                          "はじめる",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onPressed: () async {
                                          tryOutMode = true;
                                          final value = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      CameraPage()));
                                          model.audioStop();
                                          //カメラページから戻った際に計測結果をダイアログで表示
                                          if (value != null) {
                                            await showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    insetPadding:
                                                        EdgeInsets.all(10),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    title: RichText(
                                                      text: TextSpan(
                                                          style: DefaultTextStyle
                                                                  .of(context)
                                                              .style,
                                                          children: [
                                                            TextSpan(
                                                                text:
                                                                    "計測評価は...",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        22)),
                                                            TextSpan(
                                                                text:
                                                                    "${((value[1] / value[0]) * 100).toStringAsFixed(1)}",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        30,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .greenAccent
                                                                        .shade700)),
                                                            TextSpan(
                                                                text: "点",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 22,
                                                                )),
                                                            if (Utils.nekoMode)
                                                              TextSpan(
                                                                  text: "ニャ",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        22,
                                                                  )),
                                                            TextSpan(
                                                                text: "!!!",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 22,
                                                                )),
                                                          ]),
                                                    ),
                                                    content: Container(
                                                      height: 300,
                                                      width: 300,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: Colors
                                                              .greenAccent
                                                              .shade700,
                                                          width: 3,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10.0),
                                                        child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    "計測時間",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            20),
                                                                  ),
                                                                  Text(
                                                                    "${value[0] ~/ 60 ~/ 60}時間${value[0] ~/ 60 % 60}分${value[0] % 60}秒",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            20),
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    "姿勢(良)",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            20,
                                                                        color: Colors
                                                                            .greenAccent
                                                                            .shade700),
                                                                  ),
                                                                  Text(
                                                                    "${value[1] ~/ 60 ~/ 60}時間${value[1] ~/ 60 % 60}分${value[1] % 60}秒",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                      color: Colors
                                                                          .greenAccent
                                                                          .shade700,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    "姿勢(猫背)",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            20,
                                                                        color: Colors
                                                                            .red),
                                                                  ),
                                                                  Text(
                                                                    "${value[2] ~/ 60 ~/ 60}時間${value[2] ~/ 60 % 60}分${value[2] % 60}秒",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            20,
                                                                        color: Color(
                                                                            0xffff1a1a)),
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      Text(
                                                                        "警告回数 ",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                20),
                                                                      ),
                                                                      Text(
                                                                        "(設定：${Utils.timeToNotification}秒)",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                15),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Text(
                                                                    "${value[3]}回",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            20),
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    "グリーンラインの幅",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15),
                                                                  ),
                                                                  Text(
                                                                    Utils.nekoMode ==
                                                                            true
                                                                        ? "${value[4]}ニャ"
                                                                        : value[
                                                                            4],
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 20,
                                                              ),
                                                              Row(children: [
                                                                Expanded(
                                                                    flex: 1,
                                                                    child: Align(
                                                                        alignment: Alignment.center,
                                                                        child: Container(
                                                                            height: 100,
                                                                            child: AspectRatio(
                                                                              aspectRatio: 1,
                                                                              child: PieChart(
                                                                                PieChartData(
                                                                                  borderData: FlBorderData(show: false),
                                                                                  startDegreeOffset: 270,
                                                                                  sectionsSpace: 0,
                                                                                  centerSpaceRadius: 40,
                                                                                  sections: _showingSectionsOnDialog(value),
                                                                                ),
                                                                              ),
                                                                            )))),
                                                                Expanded(
                                                                    flex: 1,
                                                                    child: Container(
                                                                        height: 100,
                                                                        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                                                                          Row(
                                                                            children: [
                                                                              Text(
                                                                                "●",
                                                                                style: TextStyle(
                                                                                  fontSize: 23,
                                                                                  color: Colors.greenAccent.shade700,
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                "：${((value[1] / value[0]) * 100).toStringAsFixed(1)}％",
                                                                                style: TextStyle(
                                                                                  fontSize: 20,
                                                                                  color: Colors.greenAccent.shade700,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Row(children: [
                                                                            Text(
                                                                              "●",
                                                                              style: TextStyle(fontSize: 23, color: Color(0xffff1a1a)),
                                                                            ),
                                                                            Text(
                                                                              "：${((value[2] / value[0]) * 100).toStringAsFixed(1)}％",
                                                                              style: TextStyle(fontSize: 20, color: Color(0xffff1a1a)),
                                                                            ),
                                                                          ]),
                                                                        ]))),
                                                              ]),
                                                            ]),
                                                      ),
                                                    ),
                                                    actions: [
                                                      Center(
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        30.0),
                                                            child: Text(
                                                              "OK",
                                                              style: TextStyle(
                                                                  fontSize: 25,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          50),
                                                            ),
                                                            backgroundColor:
                                                                Colors
                                                                    .greenAccent
                                                                    .shade700,
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  );
                                                });
                                          }
                                          tryOutMode = false;
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text(
                                          "戻る",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  ),
                                );
                              });
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 5,
                            backgroundColor: Colors.greenAccent.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            )),
                        child: Text(
                          "おためしモード",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: size * 0.08),
                    //Googleでサインイン
                    SignInButton(
                        buttonType: ButtonType.google,
                        onPressed: () async {
                          model.startLoading();
                          try {
                            await model.signInWithGoogle();
                          } catch (e) {
                            if (e.toString() !=
                                "Null check operator used on a null value") {
                              await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
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
                          model.endLoading();
                        }),
                    SizedBox(height: size * 0.08),
                    //Appleでサインイン
                    SignInButton(
                        buttonType: ButtonType.apple,
                        onPressed: () async {
                          model.startLoading();
                          try {
                            await model.signInWithApple();
                          } catch (e) {
                            if (e.toString() !=
                                "SignInWithAppleAuthorizationError(AuthorizationErrorCode.canceled, The operation couldn’t be completed. (com.apple.AuthenticationServices.AuthorizationError error 1001.))") {
                              print(e);
                              await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
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
                          model.endLoading();
                        }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//ページの構成内容
class _PageContents extends StatelessWidget {
  _PageContents({
    required this.size,
    required this.image,
    required this.title,
    required this.description,
  });

  final size;
  final String image;
  final String title;
  final Widget description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5.0, right: 5.0, left: 5.0),
          child: Container(
            height: size,
            width: size,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(45),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Container(
          height: size * 0.2,
          width: double.infinity,
          child: Center(
            child: FittedBox(
              child: Text(
                title,
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent.shade700),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: description,
        ),
      ],
    );
  }
}

//計測を終えた後アラートダイアログに結果を円グラフで表示
List<PieChartSectionData> _showingSectionsOnDialog(value) {
  return List.generate(2, (i) {
    final radius = 15.0;
    switch (i) {
      case 0:
        return PieChartSectionData(
          color: Color(0xff00c904),
          value: value[1].toDouble(),
          radius: radius,
          showTitle: false,
        );
      case 1:
        return PieChartSectionData(
          color: Color(0xffff1a1a),
          value: value[2].toDouble(),
          showTitle: false,
          radius: radius,
        );
      default:
        throw Error();
    }
  });
}
