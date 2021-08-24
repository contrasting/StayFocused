import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stay_focused/strings.dart';
import 'package:path_provider_windows/src/folders.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'main.dart';

// https://superuser.com/questions/988547/allow-only-white-listed-sites-on-windows-10

void startBlocking() async {
  if (!preferences.containsKey(WHITELISTED)) return;

  final ls = LineSplitter();
  final hostsFile = await _getHostsFile();
  final hostsList = ls.convert(await hostsFile.readAsString());

  if (hostsList.contains(HOSTS_START)) {
    // hosts file already exists. We should update it instead of appending
    _removeExisting(hostsList);
  }

  final whitelist = ls.convert(preferences.getString(WHITELISTED)!);
  final lookups = <Future<List<InternetAddress>>>[];

  // perform DNS lookup
  for (String host in whitelist) {
    lookups.add(InternetAddress.lookup(host, type: InternetAddressType.IPv4));
  }
  final lookupsResult = await Future.wait(lookups);

  // indicate start
  hostsList.add(HOSTS_START);

  // save DNS queries
  for (final addresses in lookupsResult) {
    for (final address in addresses) {
      hostsList.add('${address.address}  ${address.host}');
    }
  }

  // save null routes
  hostsList.addAll(await _getNullRoutes());

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

List<String>? _nullRoutes;

Future<List<String>> _getNullRoutes() async {
  if (_nullRoutes != null) return _nullRoutes!;
  final routes = await rootBundle.loadString('resources/null_route.txt');
  _nullRoutes = LineSplitter().convert(routes);
  return _nullRoutes!;
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
    startBlocking();
  }
}
