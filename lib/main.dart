import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stay_focused/colors.dart';
import 'package:stay_focused/stats.dart';

import 'data.dart';
import 'home.dart';
import 'hosts.dart';

late final SharedPreferences preferences;

void main() async {
  preferences = await SharedPreferences.getInstance();
  await loadData();
  runApp(const StayFocused());
}

class StayFocused extends StatelessWidget {
  const StayFocused({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stay Focused',
      theme: ThemeData(
        primarySwatch: kThemeSwatch,
        fontFamily: 'Eurostile',
      ),
      home: const Navigation(),
    );
  }
}

class Navigation extends StatefulWidget {
  const Navigation({Key? key}) : super(key: key);

  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  final _children = <Widget>[
    const Home(),
    const Stats(),
    const Hosts(),
  ];

  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NavigationRail(
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.home),
              label: Text('Home'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.analytics),
              label: Text('Stats'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.change_history),
              label: Text('Hosts'),
            ),
          ],
          selectedIndex: _index,
          onDestinationSelected: (index) {
            setState(() {
              _index = index;
            });
          },
        ),
        Expanded(
          child: _children[_index],
        ),
      ],
    );
  }
}
