import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "ヘルプ",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.greenAccent.shade700),
        ),
      ),
      body: Center(
        child: Container(
          child: Text("help_page"),
        ),
      ),
    );
  }
}
