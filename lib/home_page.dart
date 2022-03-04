import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:posture_correction/camera_page.dart';
import 'package:posture_correction/home_model.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeModel>(
        create: (_) => HomeModel()..loadmodel(),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("posture correction"),
            ),
            body: Consumer<HomeModel>(builder: (context, model, child) {
              return Center(
                child: InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => CameraPage()));
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
              );
            }),
          );
        });
  }
}
