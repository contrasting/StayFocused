import 'package:flutter/material.dart';
import 'package:stay_focused/strings.dart';

import 'main.dart';

class Hosts extends StatefulWidget {
  const Hosts({Key? key}) : super(key: key);

  @override
  _HostsState createState() => _HostsState();
}

class _HostsState extends State<Hosts> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (preferences.containsKey(WHITELISTED)) {
      final whitelist = preferences.getString(WHITELISTED);
      _controller.text = whitelist!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hosts to whitelist:',
              style: Theme.of(context).textTheme.headline5,
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: TextField(
                controller: _controller,
                expands: true,
                minLines: null,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: _save,
              child: Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    preferences.setString(WHITELISTED, _controller.text);
  }
}
