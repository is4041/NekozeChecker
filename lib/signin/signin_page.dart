import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:posture_correction/signin/signin_model.dart';
import 'package:posture_correction/utils.dart';
import 'package:provider/provider.dart';
import 'package:sign_button/sign_button.dart';
import 'package:transparent_image/transparent_image.dart';

import '../bottomnavigation.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
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
                      PageOne(model, screenSize),
                      PageTwo(model, screenSize),
                      PageThree(model, screenSize),
                      PageFour(model, screenSize),
                      PageFive(model, screenSize),
                    ]
                  : [
                      PageFive(model, screenSize),
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
                              height: screenSize.height * 0.15,
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
                                        onPressed: model.activePage < 4
                                            ? () {
                                                pageController.nextPage(
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    curve: Curves.ease);
                                              }
                                            : () {},
                                        style: ElevatedButton.styleFrom(
                                            primary: model.activePage < 4
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
//ページの高さは合計でscreenSize.height * 0.85とする
class PageOne extends StatelessWidget {
  final SignInModel model;
  // ignore: prefer_typing_uninitialized_variables
  var screenSize;
  PageOne(this.model, this.screenSize);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: screenSize.height * 0.5,
          width: double.infinity,
          child: Image.asset(
            "images/IMG_0196.JPG",
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(
          height: screenSize.height * 0.1,
          width: double.infinity,
          child: Center(
            child: FittedBox(
              child: Text(
                "Posture Correctionへようこそ",
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent.shade700),
              ),
            ),
          ),
        ),
        SizedBox(
          height: screenSize.height * 0.25,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Column(
              children: [
                Text(
                  "Posture Correctionはゲームやデスクワーク中の前傾姿勢による顔の位置変化をカメラでリアルタイムに読み取り姿勢不良を検知すると音で警告してくれるアプリです。",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "使い方の説明は次ページから→",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

//2ページ目
//ページの高さは合計でscreenSize.height * 0.85とする
class PageTwo extends StatelessWidget {
  final SignInModel model;
  // ignore: prefer_typing_uninitialized_variables
  var screenSize;
  PageTwo(this.model, this.screenSize);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: screenSize.height * 0.5,
          width: double.infinity,
          child: Image.asset(
            "images/IMG_0203.JPG",
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(
          height: screenSize.height * 0.1,
          width: double.infinity,
          child: Center(
            child: FittedBox(
              child: Text(
                "スマートフォンをセットする",
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent.shade700),
              ),
            ),
          ),
        ),
        SizedBox(
          height: screenSize.height * 0.25,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "スマートフォンをモニター付近にセットしたら緑色のstartボタンを押してカメラを起動しましょう。",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "※スマートフォン用スタンド（100均などで購入できます）を使うことをおすすめしますが立てかけられる物なら何でもOKです。例：コップ",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

//3ページ目
//ページの高さは合計でscreenSize.height * 0.85とする
class PageThree extends StatelessWidget {
  final SignInModel model;
  // ignore: prefer_typing_uninitialized_variables
  var screenSize;
  PageThree(this.model, this.screenSize);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Center(
              child: SizedBox(
                height: screenSize.height * 0.5,
                width: double.infinity,
                child: Image.asset(
                  "images/IMG_Unsplash.jpg",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: screenSize.height * 0.1,
          width: double.infinity,
          child: Center(
            child: FittedBox(
              child: Text(
                "白点の位置を調整する",
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent.shade700),
              ),
            ),
          ),
        ),
        SizedBox(
          height: screenSize.height * 0.25,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "姿勢を正し、鼻の位置に表示される白点がグリーンラインの枠内に収まるように端末の位置を調整します。",
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  "白点が枠内から出ないように姿勢を保ち続けましょう。",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "白点がグリーンラインの枠内から出たまま一定時間経つと警告音が鳴ります。",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

//4ページ目
//ページの高さは合計でscreenSize.height * 0.85とする
class PageFour extends StatelessWidget {
  final SignInModel model;
  // ignore: prefer_typing_uninitialized_variables
  var screenSize;
  PageFour(this.model, this.screenSize);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: screenSize.height * 0.5,
          width: double.infinity,
          child: Image.asset(
            "images/IMG_0215.jpg",
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(
          height: screenSize.height * 0.1,
          width: double.infinity,
          child: Center(
            child: FittedBox(
              child: Text(
                " 使わなくなった端末を活用できます ",
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent.shade700),
              ),
            ),
          ),
        ),
        SizedBox(
          height: screenSize.height * 0.25,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Text(
              "使わなくなった端末はありませんか？\nカメラ使用中は他の操作ができないためPC作業中やゲーム中にも今お使いの端末でメール返信などの操作をされる方は当アプリを、使わなくなった端末にインストールして使用するということもできます。",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}

//5ページ目
//ページの高さは合計でscreenSize.height * 0.85とする
class PageFive extends StatelessWidget {
  final SignInModel model;
  // ignore: prefer_typing_uninitialized_variables
  var screenSize;
  PageFive(this.model, this.screenSize);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            SizedBox(
              height: screenSize.height * 0.5,
              width: double.infinity,
              child: Opacity(
                opacity: 0.8,
                child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image:
                      "https://images.unsplash.com/photo-1549082984-1323b94df9a6?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(
                height: screenSize.height * 0.5,
                width: double.infinity,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Posture",
                        style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Colors.greenAccent),
                      ),
                      Text(
                        "Correction",
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
          ],
        ),
        SizedBox(
          height: screenSize.height * 0.1,
        ),
        SizedBox(
          height: 45,
          width: 280,
          child: ElevatedButton(
            onPressed: () async {
              model.startLoading();
              try {
                await model.signInWithAnonymousUser();
              } catch (e) {
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: Text("エラー"),
                        content: Text("通信状態をご確認ください"),
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
              model.endLoading();
            },
            style: ElevatedButton.styleFrom(
                elevation: 5,
                primary: Colors.greenAccent.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                )),
            child: Text(
              "はじめる",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        //Googleでサインイン
        SignInButton(
            buttonType: ButtonType.google,
            buttonSize: ButtonSize.large,
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
      ],
    );
  }
}
