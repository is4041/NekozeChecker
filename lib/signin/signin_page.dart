import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:posture_correction/signin/signin_model.dart';
import 'package:provider/provider.dart';
import 'package:sign_button/sign_button.dart';

import '../bottomnavigation.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignInModel>(
        create: (_) => SignInModel(),
        builder: (context, snapshot) {
          return Scaffold(
            body: Consumer<SignInModel>(builder: (context, model, child) {
              final PageController pageController =
                  PageController(initialPage: 0);

              final List<Widget> pages = [
                PageOne(model),
                PageTwo(model),
                PageThree(model),
                PageFour(model),
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
                          //todo 初回登録後は非表示にする
                          Positioned(
                            height: 150,
                            right: 0,
                            bottom: 0,
                            left: 0,
                            child: Column(
                              children: [
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
                                                    ? Colors.green
                                                    : Colors.grey.shade300,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Container(
                                    height: 40,
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: model.activePage < 3
                                          ? () {
                                              pageController.nextPage(
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  curve: Curves.ease);
                                            }
                                          : () {},
                                      style: ElevatedButton.styleFrom(
                                          primary: model.activePage < 3
                                              ? Colors.green
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
                                        // style: TextStyle(fontSize: 40),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
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
class PageOne extends StatelessWidget {
  final SignInModel model;
  PageOne(this.model);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 100,
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 200,
                // width: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                ),
                child: Image.asset("images/IMG_0107.jpg"),
              ),
            ),
            Expanded(
              child: Container(),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Container(),
            ),
            Expanded(
              child: Container(
                height: 200,
                // width: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                ),
                child: Image.asset("images/IMG_0106.jpg"),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 30,
        ),
        Container(
          color: Colors.green.shade100,
          alignment: Alignment.center,
          child: Text(
            "Posture Correctionへようこそ",
            style: TextStyle(
                fontSize: 25, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: Column(
            children: [
              Text(
                "Posture Correctionは顔の位置を検知し、猫背になっていると音で知らせてくれるアプリです。",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

//2ページ目
class PageTwo extends StatelessWidget {
  final SignInModel model;
  PageTwo(this.model);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 100,
        ),
        Center(
          child: Container(
            // height: 350,
            // width: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child:
                Image.asset("images/davide-baraldi-Nzmyp6LsgNM-unsplash.jpg"),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        Container(
          color: Colors.green.shade100,
          alignment: Alignment.center,
          child: Text(
            "スマートフォンを\n画面横にセットする",
            style: TextStyle(
                fontSize: 25, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: Text(
            "スマートフォン用スタンドを使うのがおすすめですが（100均などで購入できます）立てかけられる物なら何を使っても大丈夫です。",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}

//3ページ目
class PageThree extends StatelessWidget {
  final SignInModel model;
  PageThree(this.model);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 50,
        ),
        Stack(
          children: [
            Center(
              child: Container(
                height: 350,
                width: 210,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                // color: Colors.red,
              ),
            ),
            Center(
              child: Container(
                height: 350,
                width: 200,
                // color: Colors.red,
                child:
                    Image.asset("images/lesly-juarez-RukI4qZGlQs-unsplash.jpg"),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 30,
        ),
        Container(
          alignment: Alignment.center,
          color: Colors.green.shade100,
          child: Text(
            "位置を調整する",
            style: TextStyle(
                fontSize: 25, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ),

        SizedBox(
          height: 30,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "1. 姿勢を正す",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 30,
                    // color: Colors.green,
                    child: Center(
                      child: Text(
                        "2. ",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      height: 90,
                      // color: Colors.green,
                      child: Text(
                        "鼻の位置に表示される白点が緑のラインよりわずかに上にくるように端末の位置を調整する",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "3. OKボタンを押してはじめましょう！",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),

        // Text(
        //   "3.",
        //   style: TextStyle(fontSize: 20),
        // ),
      ],
    );
  }
}

//4ページ目
class PageFour extends StatelessWidget {
  final SignInModel model;
  PageFour(this.model);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 216,
              width: 216,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
            ),
            SizedBox(
              height: 80,
            ),
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
                  }
                  model.endLoading();
                }),
            const SizedBox(height: 30),
            SizedBox(
              // height: 256,
              // width: 256,
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
                            content:
                                Text("ユーザーデータの作成に失敗しました。通信環境の良いところで再度試してください。"),
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
                    primary: Colors.green,
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
          ],
        ),
      ),
    );
  }
}
