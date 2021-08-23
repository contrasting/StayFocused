import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stay_focused/colors.dart';

import 'home.dart';

late final SharedPreferences preferences;

void main() async {
  preferences = await SharedPreferences.getInstance();
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
              icon: Icon(Icons.update),
              label: Text('???'),
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
