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
                      _PageOne(screenSize),
                      _PageTwo(screenSize),
                      _PageThree(screenSize),
                      _PageFour(screenSize),
                      _PageFive(model, screenSize),
                    ]
                  : [
                      _PageFive(model, screenSize),
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
                                            backgroundColor: model.activePage <
                                                    4
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
  _PageOne(this.screenSize);

  final screenSize;

  @override
  Widget build(BuildContext context) {
    return _PageContents(
      screenSize: screenSize,
      image: "images/IMG_0196.JPG",
      title: "Posture Correctionへようこそ",
      description: Column(
        children: [
          Text(
            "Posture Correctionはゲームやデスクワーク中の前傾姿勢・居眠りを検知すると警告音でお知らせします。",
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
  _PageTwo(this.screenSize);

  final screenSize;

  @override
  Widget build(BuildContext context) {
    return _PageContents(
      screenSize: screenSize,
      image: "images/IMG_0203.JPG",
      title: "スマートフォンをセットする",
      description: Column(
        children: [
          Text(
            "モニター付近にセットしたらstartボタンを押してカメラを起動しましょう。",
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
    );
  }
}

//3ページ目
class _PageThree extends StatelessWidget {
  _PageThree(this.screenSize);

  final screenSize;

  @override
  Widget build(BuildContext context) {
    return _PageContents(
      screenSize: screenSize,
      image: "images/IMG_Unsplash.jpg",
      title: "白点の位置を調整する",
      description: Column(
        children: [
          Text(
            "姿勢を正し、鼻の位置に表示される白点がグリーンラインの枠内に収まるように端末の位置を調整します。\n白点が枠内から出ないように姿勢を維持しましょう。",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "白点がグリーンラインの枠内から出たまま一定時間経つと警告音が鳴ります。",
            style: TextStyle(fontSize: 12),
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
      screenSize: screenSize,
      image: "images/IMG_0215.jpg",
      title: " 使わなくなった端末を活用できます ",
      description: Column(
        children: [
          Text(
            "Googleでサインインすると複数の端末の間でデータの同期ができます。\n同期をすることで今お使いの端末をデータ閲覧用、使わなくなった端末をカメラ計測用にするということもできます。",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

//5ページ目
class _PageFive extends StatelessWidget {
  _PageFive(this.model, this.screenSize);

  final SignInModel model;
  final screenSize;

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
                backgroundColor: Colors.greenAccent.shade700,
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

//ページの構成内容
class _PageContents extends StatelessWidget {
  _PageContents({
    required this.screenSize,
    required this.image,
    required this.title,
    required this.description,
  });

  final screenSize;
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
            height: screenSize.height * 0.5,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(45),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(
          height: screenSize.height * 0.1,
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
        SizedBox(
          height: screenSize.height * 0.25,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: description,
          ),
        ),
      ],
    );
  }
}
