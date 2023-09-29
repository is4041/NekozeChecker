import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 1,
        backgroundColor: Colors.grey[50],
        title: Text(
          "ヘルプ",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.greenAccent.shade700),
        ),
      ),
      body: Scrollbar(
        child: ListView(
          children: [
            //Q & A
            Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 10.0),
              child: Text(
                "Q & A",
                style: TextStyle(fontSize: 20),
              ),
            ),
            _Question(
                question: "カメラ使用中に白点が正しく鼻の位置に表示されないのですが？",
                answer:
                    "逆光などでうまく顔の位置情報を取得できない場合があります。場所を変えたりカーテンを閉めるなどしてもう一度お試しください。"),
            _Question(
                question: "停止ボタンを押さずに離席してしまった場合、計測データはどうなりますか？",
                answer: "停止ボタンを押さなくても顔が画面外に出ると自動敵にタイマーが停止するので計測データに影響はありません。"),
            _Question(
                question: "離席中に『計測停止中』と表示されずに白点が誤作動を起こすのですが？",
                answer:
                    "画面に映っている荷物や衣服などを顔と誤認識する場合があります。荷物を退けるか、離席中だけ端末を違う方向に向けておくなど工夫してみてください。"),
            _Question(
                question: "ラインカラーが黄色だったときの時間やその時に鳴った警告音の記録はどうなりますか？",
                answer: "時間は姿勢（良）として記録されますが、警告音は記録されません。"),
            Divider(
              thickness: 5,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "使い方",
                style: TextStyle(fontSize: 20),
              ),
            ),
            //チュートリアル
            _PageContents(
              screenSize: screenSize,
              image: "images/IMG_0203.JPG",
              title: "1.スマートフォンをセットする",
              description: Column(
                children: [
                  Text(
                    "椅子に座ったら上の画像のようにスマートフォンをセットし、STARTボタンを押してカメラを起動しましょう。",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "※スマートフォン用スタンド（100均などで購入できます）を使うのがおすすめですが立てかけられる物なら何を使っても大丈夫です。",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            Divider(
              thickness: 1,
            ),
            _PageContents(
              screenSize: screenSize,
              image: "images/IMG_Unsplash.jpg",
              title: "2.画面内に顔が映るようにする",
              description: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          TextSpan(
                              text: "1. ",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: "画面内に顔が映るように端末の位置を調整する。",
                              style: TextStyle(fontSize: 16)),
                          TextSpan(
                              text: "（白点とグリーンラインは自動調整されます。）",
                              style: TextStyle(
                                fontSize: 12,
                              )),
                        ]),
                  ),
                  SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          TextSpan(
                              text: "2. ",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: "姿勢を正す。", style: TextStyle(fontSize: 16))
                        ]),
                  ),
                  SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          TextSpan(
                              text: "3. ",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: "計測スタート！白点が枠内から出ないように姿勢を保ち続けましょう。",
                              style: TextStyle(fontSize: 16))
                        ]),
                  ),
                ],
              ),
            ),
            Divider(
              thickness: 1,
            ),
            _PageContents(
              screenSize: screenSize,
              image: "images/IMG_0295.JPG",
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
                            text:
                                "・・・猫背とは判定されませんが警告音はなります。この間姿勢は（良）としてカウントされます。",
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
                        TextSpan(
                            text: "・・・姿勢良好です。", style: TextStyle(fontSize: 16)),
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
                            text: "・・・猫背です。警告音がなります。",
                            style: TextStyle(fontSize: 16)),
                      ])),
                ],
              ),
            ),
            Divider(
              thickness: 5,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "オススメ！",
                style: TextStyle(fontSize: 20),
              ),
            ),
            _PageContents(
              screenSize: screenSize,
              image: "images/IMG_0215.jpg",
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
            ),
            SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}

//Questionクラス
class _Question extends StatelessWidget {
  _Question({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        color: Colors.grey.withOpacity(0.2),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  color: Colors.greenAccent.shade700,
                  child: Text(
                    "Q",
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Flexible(
                  child: Text(
                    question,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.greenAccent.shade700),
                      color: Colors.white),
                  child: Text(
                    "A",
                    style: TextStyle(
                        fontSize: 30, color: Colors.greenAccent.shade700),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Flexible(child: Text(answer)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//PageContentsクラス
class _PageContents extends StatelessWidget {
  _PageContents(
      {required this.screenSize,
      required this.image,
      required this.title,
      required this.description});

  final screenSize;
  final String image;
  final String title;
  final Widget description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
          height: screenSize.height * 0.5,
          width: double.infinity,
          child: Image.asset(
            image,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 50.0, left: 50),
          child: description,
        ),
      ],
    );
  }
}
