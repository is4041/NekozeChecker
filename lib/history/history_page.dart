import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:posture_correction/history/history_model.dart';
import 'package:provider/provider.dart';

import '../data.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HistoryModel>(
        create: (_) => HistoryModel()..fetchData(),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                "履歴",
                style: TextStyle(color: Colors.green),
              ),
              backgroundColor: Colors.white,
            ),
            body: Center(
              child: Consumer<HistoryModel>(builder: (context, model, child) {
                final List<Data>? data = model.data;
                data?.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                if (data == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                final List<Widget> widgets = data
                    .map(
                      (data) => Visibility(
                        visible: data.userId == model.userId,
                        child: Slidable(
                          endActionPane: ActionPane(
                            motion: DrawerMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (_) async {
                                  await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("合計平均値が変化しますがデータを削除しますか？"),
                                        actions: [
                                          TextButton(
                                            child: const Text(
                                              "はい",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                            onPressed: () async {
                                              await model.delete(data);
                                              await model
                                                  .calculateTotalAverage();
                                              await model.upDateTotalAverage();
                                              model.fetchData();
                                              Navigator.of(context).pop();
                                              final snackBar = SnackBar(
                                                  backgroundColor: Colors.red,
                                                  content: Text("削除しました"));
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(snackBar);
                                            },
                                          ),
                                          TextButton(
                                            child: Text("いいえ"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          )
                                        ],
                                      );
                                    },
                                  );

                                  // await showDialog(
                                  //   context: context,
                                  //   builder: (context) {
                                  //     return CupertinoAlertDialog(
                                  //       title:
                                  //           Text("合計平均値が変化しますが\nデータを削除しますか？"),
                                  //       actions: [
                                  //         CupertinoDialogAction(
                                  //           child: Text(
                                  //             "はい",
                                  //             style:
                                  //                 TextStyle(color: Colors.red),
                                  //           ),
                                  //           onPressed: () async {
                                  //             await model.delete(data);
                                  //             await model
                                  //                 .calculateTotalAverage();
                                  //             await model.upDateTotalAverage();
                                  //             model.fetchData();
                                  //             Navigator.of(context).pop();
                                  //             final snackBar = SnackBar(
                                  //                 backgroundColor: Colors.red,
                                  //                 content: Text("削除しました"));
                                  //             ScaffoldMessenger.of(context)
                                  //                 .showSnackBar(snackBar);
                                  //           },
                                  //         ),
                                  //         CupertinoDialogAction(
                                  //           child: Text("いいえ"),
                                  //           onPressed: () {
                                  //             Navigator.pop(context);
                                  //           },
                                  //         ),
                                  //       ],
                                  //     );
                                  //   },
                                  // );
                                },
                                backgroundColor: Colors.red,
                                icon: Icons.delete,
                                label: "削除",
                              )
                            ],
                          ),
                          child: Card(
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(int.parse(data.seconds) ~/ 60 > 0
                                      ? "計測時間：${int.parse(data.seconds) ~/ 60}分${int.parse(data.seconds) % 60}秒"
                                      : "計測時間：${int.parse(data.seconds) % 60}秒"),
                                  Text("通知回数：${data.numberOfNotifications}回"),
                                  Row(
                                    children: [
                                      Text(
                                        data.averageTime != ""
                                            ? "${data.averageTime}分"
                                            : "猫背は検知されていません",
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        data.averageTime != "" ? "に一回猫背" : "",
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Text(data.createdAt.substring(0, 10)),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList();

                return ListView(
                  children: widgets,
                );
              }),
            ),
          );
        });
  }
}
