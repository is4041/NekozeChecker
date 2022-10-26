import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:posture_correction/setting/setting_model.dart';
import 'package:posture_correction/signin/signin_page.dart';
import 'package:provider/provider.dart';

final auth = FirebaseAuth.instance;

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SettingModel>(
        create: (_) => SettingModel()..getName(),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                "設定",
                style: TextStyle(color: Colors.green),
              ),
              backgroundColor: Colors.white,
            ),
            body: Consumer<SettingModel>(builder: (context, model, child) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                        child: InkWell(
                      onTap: () async {
                        try {
                          // await auth.signOut();
                          await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("削除しますか？"),
                                  actions: [
                                    TextButton(
                                      child: Text("はい"),
                                      onPressed: () async {
                                        // await FirebaseAuth.instance.currentUser!
                                        //     .delete();
                                        await model.deleteUser();

                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text("いいえ"),
                                      onPressed: () async {
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
                                        // Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                );
                              });
                        }

                        print("done");
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 35,
                            width: 220,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black)),
                            child: const Center(child: Text("ユーザー削除")),
                          ),
                          Container(
                            height: 35,
                            child: Center(
                                child: Text(model.userid != null
                                    ? model.userid.toString()
                                    : "?")),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              );
            }),
          );
        });
  }
}
