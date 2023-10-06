import 'package:cloud_firestore/cloud_firestore.dart';

class Data {
  Data(DocumentSnapshot doc) {
    createdAt = doc["createdAt"];
    greenLineRange = doc["greenLineRange"];
    measuringBadPostureSec = doc["measuringBadPostureSec"];
    measuringSec = doc["measuringSec"];
    notificationCounter = doc["notificationCounter"];
    timeToNotification = doc["timeToNotification"];
    memo = doc["memo"];
    documentID = doc.id;
  }
  String? createdAt;
  num? greenLineRange;
  num? measuringBadPostureSec;
  num? measuringSec;
  int? notificationCounter;
  int? timeToNotification;
  String? memo;
  String? documentID;
}
