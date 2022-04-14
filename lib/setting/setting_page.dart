import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Setting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("setting")),
      body: Center(
          child: InkWell(
        onTap: () async {
          try {
            await FirebaseAuth.instance.currentUser!.delete();
            await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("削除しました"),
                    actions: [
                      TextButton(
                        child: Text("ok"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                });
          } catch (e) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(e.toString()),
                    actions: [
                      TextButton(
                        child: Text("ok"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                });
          }

          print("done");
        },
        child: Container(
          height: 35,
          width: 220,
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          child: const Center(child: Text("ユーザー削除")),
        ),
      )),
    );
  }
}
