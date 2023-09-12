import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:posture_correction/signin/signin_page.dart';

import 'camera/camera_model.dart';
import 'camera/camera_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // アプリがバックグラウンドに移行した場合の処理
      notificationTimer?.cancel();
      audioPlayer.stop();
      timer?.cancel();
      badPostureTimer?.cancel();
      detection = false;
      isCounting = false;
      isAdjusting = true;
      if (measuredOverOneSec == false) return;
      dataExist = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SignInPage());
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: SignInPage(),
//     );
//   }
// }
