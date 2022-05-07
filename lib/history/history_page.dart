import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:posture_correction/history/history_model.dart';
import 'package:provider/provider.dart';

import '../data.dart';

class History extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HistoryModel>(
        create: (_) => HistoryModel()..fetchData(),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(title: Text("履歴")),
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
                                          title:
                                              Text("合計平均値が変化しますがデータを削除しますか？"),
                                          actions: [
                                            TextButton(
                                              child: const Text("はい"),
                                              onPressed: () async {
                                                await model.delete(data);
                                                await model
                                                    .calculateTotalAverage();
                                                await model
                                                    .upDateTotalAverage();
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
                                      });
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
                                  Text("計測時間：${data.seconds}秒"),
                                  Text("通知回数：${data.numberOfNotifications}回"),
                                  Text(data.averageTime != "＊"
                                      ? "${data.averageTime}秒に1回猫背"
                                      : "猫背にはなっていません"),
                                  // Text("userId：${data.userId}"),
                                  // Text(data.createdAt),
                                ],
                              ),
                              trailing: Text(data.createdAt.substring(0, 10)),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList();
                // if(widgets.toString() != "infinity")
                return ListView(
                  children: widgets,
                );
              }),
            ),
          );
        });
  }
}
