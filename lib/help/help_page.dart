import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double size =
        screenWidth < screenHeight / 2 ? screenWidth : screenHeight / 2;
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            _Question(
                question: "グリーンラインの位置は画面内であればどこに固定してもかまいませんか？",
                answer:
                    "画面内に2本表示されていれば好きな位置に固定していただいて大丈夫ですが、画面ギリギリに固定するとうまく計測できないことがあるので基本的には画面中央をおすすめします。"),
            _Question(
                question: "カメラ使用中に白点が正しく鼻の位置に表示されないのですが？",
                answer:
                    "逆光などでうまく顔の位置情報を取得できない場合があります。場所を変えたりカーテンを閉めるなどしてもう一度お試しください。"),
            _Question(
                question: "停止ボタンを押さずに離席してしまった場合、計測データはどうなりますか？",
                answer: "停止ボタンを押さなくても顔が画面外に出ると自動敵にタイマーが停止するので計測データに影響はありません。"),
            _Question(
                question: "離席中(停止ボタン押さず)に『計測停止中』と表示されずに白点が誤作動を起こすのですが？",
                answer:
                    "画面に映っている荷物や衣服などを顔と誤認識する場合があります。荷物を退けるか、離席中だけ端末を違う方向に向けておくなど工夫してみてください。"),
            _Question(
                question: "一度計測を始めたら終えるまで再度設定を変更できないのはなぜですか？",
                answer: "途中で設定を変更できてしまうと正確なデータを得ることが出来ないためです。"),
            _Question(
                question: "ラインカラーが黄色だったときの時間やその時に鳴った警告音の記録はどうなりますか？",
                answer: "時間は姿勢（良）として記録されますが、警告音は記録されません。"),
            // _Question(
            //     question:
            //         "匿名で認証した(パスワードなしで登録した)アカウントが一定期間経って自動ログアウトされたので再ログインしたいのですが？",
            //     answer: "匿名で認証したアカウントにはログインに必要なパスワードがないので再ログインは不可となります。"),
            Divider(
              thickness: 5,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "使い方",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            //チュートリアル
            _PageContents(
              size: size,
              image: "images/IMG_0345.JPG",
              title: "1. スマートフォンをセットする",
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
              size: size,
              image: "images/IMG_Unsplash.jpg",
              title: "2. カメラに顔が映るようにする",
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
                              text: "画面にグリーンラインが表示されたら姿勢を正します。",
                              style: TextStyle(fontSize: 16)),
                          TextSpan(
                              text: "（白点とグリーンラインは鼻の位置と連動し、自動調整されます。）",
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
                              text:
                                  "開始ボタン押下で計測スタート！白点がグリーンラインの間から出ないように姿勢を保ち続けましょう。\n計測開始でグリーンラインが固定されます。",
                              style: TextStyle(fontSize: 16)),
                        ]),
                  ),
                ],
              ),
            ),
            Divider(
              thickness: 1,
            ),
            _PageContents(
              size: size,
              image: "images/IMG_0310.JPG",
              title: "3. 白点とラインカラーの関係",
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            _PageContents(
              size: size,
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
                    style: TextStyle(fontWeight: FontWeight.bold),
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
                Flexible(
                    child: Text(
                  answer,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent.shade700),
                )),
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
      {required this.size,
      required this.image,
      required this.title,
      required this.description});

  final size;
  final String image;
  final String title;
  final Widget description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: size * 0.1,
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
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: SizedBox(
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
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 50.0, left: 50),
          child: description,
        ),
      ],
    );
  }
}
