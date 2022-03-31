import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Setting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("setting")),
      body: Center(
        child: Center(
            child: Container(
          child: Text("SettingPage"),
        )),
      ),
    );
  }
}
