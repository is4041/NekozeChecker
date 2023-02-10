import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:posture_correction/history/history_page.dart';
import 'package:posture_correction/home/home_page.dart';
import 'package:posture_correction/setting/setting_page.dart';

import 'graph/graph_page.dart';

class BottomNavigation extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<BottomNavigation> {
  int selectedIndex = 0;
  final pages = [
    HomePage(),
    HistoryPage(),
    GraphPage(),
    SettingPage(),
  ];

  void onTapItem(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      //候補1
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "ホーム",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "履歴"),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "グラフ"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "設定"),
        ],
        currentIndex: selectedIndex,
        onTap: onTapItem,
        selectedItemColor: Colors.greenAccent.shade700,
      ),
      //候補2
      // bottomNavigationBar: SizedBox(
      //   height: 100,
      //   child: NavigationBar(
      //     backgroundColor: Colors.transparent,
      //     selectedIndex: selectedIndex,
      //     onDestinationSelected: (index) => setState(() {
      //       selectedIndex = index;
      //     }),
      //     destinations: const [
      //       NavigationDestination(
      //         selectedIcon: Icon(
      //           Icons.home,
      //           color: Colors.green,
      //         ),
      //         icon: Icon(
      //           Icons.home,
      //           color: Colors.green,
      //         ),
      //         label: "ホーム",
      //       ),
      //       NavigationDestination(
      //         selectedIcon: Icon(
      //           Icons.history,
      //           color: Colors.green,
      //         ),
      //         icon: Icon(
      //           Icons.history,
      //           color: Colors.green,
      //         ),
      //         label: "履歴",
      //       ),
      //       NavigationDestination(
      //         selectedIcon: Icon(
      //           Icons.show_chart,
      //           color: Colors.green,
      //         ),
      //         icon: Icon(
      //           Icons.show_chart,
      //           color: Colors.green,
      //         ),
      //         label: "グラフ",
      //       ),
      //       NavigationDestination(
      //         selectedIcon: Icon(
      //           Icons.settings,
      //           color: Colors.green,
      //         ),
      //         icon: Icon(
      //           Icons.settings,
      //           color: Colors.green,
      //         ),
      //         label: "設定",
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
