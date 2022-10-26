import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../camera/camera_model.dart';
import '../data.dart';
import '../home/home_model.dart';

class SettingModel extends ChangeNotifier {
  dynamic userid;

  getName() async {
    DocumentSnapshot snapshot = await firestore.doc("users/$userId").get();
    final data = snapshot.data() as Map<String, dynamic>;
    userid = data["userId"];
    print(userid);
  }

  deleteUser() async {
    await FirebaseFirestore.instance.collection("users").doc(userid).delete();
    await FirebaseAuth.instance.currentUser!.delete();
    print("done");
  }
}
