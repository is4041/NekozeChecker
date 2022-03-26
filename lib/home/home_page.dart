import 'package:cloud_firestore/cloud_firestore.dart';
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
          ..fetchData(),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("HOME"),
            ),
            body: Consumer<HomeModel>(builder: (context, model, child) {
              final List<Data>? data = model.data;
              if (data == null) {
                return Center(child: CircularProgressIndicator());
              }
              final List<Widget> widgets = data
                  .map((data) => Column(
                        children: [
                          Text(
                            "使用時間:${data.seconds}",
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            "検知回数:${data.numberOfNotifications}",
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            "平均'${data.averageTime}'に1回猫背になっています",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ))
                  .toList();
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
                    Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12)),
                      child: ListView(
                        children: widgets,
                      ),
                    )
                  ],
                ),
              );
            }),
          );
        });
  }
}
