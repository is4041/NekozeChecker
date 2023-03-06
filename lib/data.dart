import 'package:cloud_firestore/cloud_firestore.dart';

class Data {
  Data(DocumentSnapshot doc) {
    createdAt = doc["createdAt"];
    // measuringBadPostureMin = doc["measuringBadPostureMin"];
    measuringBadPostureSec = doc["measuringBadPostureSec"];
    // measuringMin = doc["measuringMin"];
    measuringSec = doc["measuringSec"];
    notificationCounter = doc["notificationCounter"];
    timeToNotification = doc["timeToNotification"];
    title = doc["title"];
    userId = doc["userId"];
    documentID = doc.id;
  }
  String? createdAt;
  num? measuringBadPostureMin;
  num? measuringBadPostureSec;
  num? measuringMin;
  num? measuringSec;
  int? notificationCounter;
  int? timeToNotification;
  String? title;
  String? userId;
  String? documentID;
}
