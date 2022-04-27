import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:posture_correction/camera/camera_page.dart';
import 'package:posture_correction/home/home_model.dart';
import 'package:provider/provider.dart';

import '../utils.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeModel>(
        create: (_) => HomeModel()
          ..loadModel()
          ..fetchData()
          ..getTotalAverage(),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("HOME"),
            ),
            body: Consumer<HomeModel>(builder: (context, model, child) {
              final List<Data>? data = model.data;
              // final data = model.data;
              // if (data == null) {
              //   return const Center(child: SizedBox());
              // }
              // final List<Widget> widgets = data
              //     .map((data) => Column(
              //           children: [
              //             Text(
              //               "使用時間:${data.seconds}秒",
              //               style: TextStyle(fontSize: 20),
              //             ),
              //             Text(
              //               "検知回数:${data.numberOfNotifications}回",
              //               style: TextStyle(fontSize: 20),
              //             ),
              //             Text(
              //               data.numberOfNotifications != "0"
              //                   ? "約${data.averageTime}秒に1回猫背になっています"
              //                   : "猫背にはなっていません",
              //               style: TextStyle(fontSize: 20),
              //             ),
              //           ],
              //         ))
              //     .toList();
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CameraPage()));
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
                    Text("今週の平均",
                        style: TextStyle(
                          fontSize: 20.0,
                        )),
                    Container(
                      height: 120,
                      width: 200,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12)),
                      // child: ListView(
                      //     children: widgets,
                      //     ),
                      child: Text("平均約${model.totalAverage}秒に一回猫背になっています"),
                    ),
                  ],
                ),
              );
            }),
          );
        });
  }
}
