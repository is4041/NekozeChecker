import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'camera_model.dart';
import 'home_page.dart';

class CameraPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CameraModel>(
        create: (_) => CameraModel()..getCamera(),
        builder: (context, snapshot) {
          return Scaffold(
            body: Consumer<CameraModel>(builder: (context, model, child) {
              if (model.controller == null) {
                return Center(
                  child: Container(
                    child: Text("No Camera"),
                  ),
                );
              }
              return Stack(
                children: [
                  FutureBuilder<void>(
                      future: model.initializeController,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return CustomPaint(
                            foregroundPainter:
                                CirclePainter(model.recognition!),
                            child: CameraPreview(
                              model.controller!,
                              child: model.predict(),
                            ),
                          );
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: FloatingActionButton(
                        onPressed: () {
                          Navigator.pop(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()));
                        },
                        child: Icon(Icons.arrow_back_ios),
                      )),
                ],
              );
            }),
          );
        });
  }
}

class CirclePainter extends CustomPainter {
  final List? params;
  CirclePainter(this.params);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Colors.white;

    if (params!.isNotEmpty) {
      for (var re in params!) {
        var result = re["keypoints"].values.map((k) {
          // print("部位:${k["part"]}");
          // print("x座標:${k["x"]}");
          // print("y座標:${k["y"]}");
          canvas.drawCircle(
              Offset(size.width * k["x"], size.height * k["y"]), 5, paint);
        });
        print(params);
        print(result);
      }
    } else {
      print("no information");
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
