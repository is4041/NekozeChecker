import 'package:cloud_firestore/cloud_firestore.dart';

class Data {
  Data(DocumentSnapshot doc) {
    createdAt = doc["createdAt"];
    measuringBadPostureMin = doc["measuringBadPostureMin"];
    measuringBadPostureSec = doc["measuringBadPostureSec"];
    measuringMin = doc["measuringMin"];
    measuringSec = doc["measuringSec"];
    numberOfNotifications = doc["numberOfNotifications"];
    title = doc["title"];
    userId = doc["userId"];
    documentID = doc.id;
  }
  String? createdAt;
  num? measuringBadPostureMin;
  num? measuringBadPostureSec;
  num? measuringMin;
  num? measuringSec;
  num? numberOfNotifications;
  String? title;
  String? userId;
  String? documentID;
}
