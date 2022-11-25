// class Data {
//   Data(
//     this.userId,
//     this.createdAt,
//     this.seconds,
//     this.measuringMin,
//     this.measuringBadPostureMin,
//     this.numberOfNotifications,
//     this.averageTime,
//     this.id,
//   );
//   String userId;
//   String createdAt;
//   String seconds;
//   String measuringMin;
//   String measuringBadPostureMin;
//   String numberOfNotifications;
//   String averageTime;
//   String id;
// }

import 'package:cloud_firestore/cloud_firestore.dart';

class Data {
  Data(DocumentSnapshot doc) {
    averageMin = doc["averageMin"];
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
  String? averageMin;
  String? createdAt;
  String? measuringBadPostureMin;
  String? measuringBadPostureSec;
  String? measuringMin;
  String? measuringSec;
  String? numberOfNotifications;
  String? title;
  String? userId;
  String? documentID;
}
