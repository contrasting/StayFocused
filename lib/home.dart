import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isFocused ? 'Focused for ' : 'Ready to focus?',
              style: Theme.of(context).textTheme.headline3,
            ),
            const SizedBox(height: 64.0),
            FloatingActionButton(
              child: Icon(
                _isFocused ? Icons.remove_red_eye : Icons.remove_red_eye_outlined,
              ),
              onPressed: () {
                setState(() {
                  _isFocused = !_isFocused;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
