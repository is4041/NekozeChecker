import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:posture_correction/camera/camera_page.dart';
import 'package:posture_correction/home/home_model.dart';
import 'package:provider/provider.dart';

import '../data.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeModel>(
        create: (_) => HomeModel()
          ..loadModel()
          ..getTotalAverage(),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("HOME"),
            ),
            body: Consumer<HomeModel>(builder: (context, model, child) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        final value = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CameraPage()));
                        model.getTotalAverage();
                        if (value != null) {
                          await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("計測結果"),
                                  content: Container(
                                    width: 100,
                                    height: 300,
                                    child: Column(
                                      children: [
                                        Text(value[0] != "＊"
                                            ? "平均約${value[0]}秒に1回猫背になっています"
                                            : "猫背にはなっていません"),
                                        Text("計測時間：${value[1]}秒"),
                                        Text("通知回数：${value[2]}回"),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Close"))
                                  ],
                                );
                              });
                        }
                      },
                      child: Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                            child: Text(
                          "predict",
                          style: TextStyle(fontSize: 40.0, color: Colors.white),
                        )),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("全体平均",
                            style: TextStyle(
                              fontSize: 20.0,
                            )),
                        Container(
                            height: 60,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black12)),
                            child: Text(
                              model.totalAverage != "＊"
                                  ? "平均約${model.totalAverage}秒に一回猫背になっています"
                                  : "データなし",
                              style: TextStyle(
                                fontSize: 20.0,
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
              );
            }),
          );
        });
  }
}
