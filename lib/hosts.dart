import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stay_focused/strings.dart';
import 'package:path_provider_windows/src/folders.dart';

import 'main.dart';

// edit: doesn't work
// https://superuser.com/questions/988547/allow-only-white-listed-sites-on-windows-10

void startBlocking() async {
  if (!preferences.containsKey(BLACKLISTED)) return;

  final ls = LineSplitter();
  final hostsFile = await _getHostsFile();
  final hostsList = ls.convert(await hostsFile.readAsString());

  if (hostsList.contains(HOSTS_START)) {
    // hosts file already exists. We should update it instead of appending
    _removeExisting(hostsList);
  }

  final blacklist = ls.convert(preferences.getString(BLACKLISTED)!);

  // indicate start
  hostsList.add(HOSTS_START);

  // add blacklist
  for (final host in blacklist) {
    hostsList.add('0.0.0.0  $host');
  }

  // indicate end
  hostsList.add(HOSTS_END);

  hostsFile.writeAsString(hostsList.join('\n'));
}

void stopBlocking() async {
  final hostsFile = await _getHostsFile();
  final hostsList = LineSplitter().convert(await hostsFile.readAsString());
  _removeExisting(hostsList);
  hostsFile.writeAsString(hostsList.join('\n'));
}

Future<File> _getHostsFile() async {
  final systemPath = await pathProvider.getPath(WindowsKnownFolder.System);
  return File('$systemPath/drivers/etc/hosts');
}

void _removeExisting(List<String> hostsList) {
  int? start, end;
  for (int i = 0; i < hostsList.length; i++) {
    if (hostsList[i] == HOSTS_START) {
      start = i;
    } else if (hostsList[i] == HOSTS_END) {
      end = i;
      break;
    }
  }

  if (start == null || end == null) return;
  hostsList.removeRange(start, end + 1); // NB + 1
}

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
    if (preferences.containsKey(BLACKLISTED)) {
      final blacklist = preferences.getString(BLACKLISTED);
      _controller.text = blacklist!;
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
              'Hosts to blacklist:',
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
    preferences.setString(BLACKLISTED, _controller.text);
    // save should only start blocking when is focusing
    if (preferences.containsKey(SESSION_START)) {
      startBlocking();
    }
  }
}
