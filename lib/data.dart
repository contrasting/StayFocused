import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider_windows/src/folders.dart';
import 'package:stay_focused/strings.dart';

import 'main.dart';

late final File _file;
late final List<List<dynamic>> _data;
List<FocusDay>? _parsed;

// call this before using any other methods
Future<void> loadData() async {
  final documentsPath = await pathProvider.getPath(WindowsKnownFolder.Documents);
  _file = File('${documentsPath}/focus_data.csv');
  try {
    _data = await _file.openRead().transform(utf8.decoder).transform(const CsvToListConverter()).toList();
  } on FileSystemException {
    // file does not exist. Create it
    await _file.create();
    _data = [];
  }
}

void writeRow(String label, int num) {
  bool exists = false;
  for (final row in _data) {
    if (row[0] == label) {
      exists = true;
      row[1] = num;
      break;
    }
  }
  if (!exists) {
    _data.add([label, num]);
  }
  _parse();
  _file.writeAsString(const ListToCsvConverter().convert(_data));
}

int? getRow(String label) {
  for (final row in _data) {
    if (row[0] == label) return row[1];
  }
  return null;
}

class FocusDay {
  final DateTime date;
  final Duration focusedDuration;

  FocusDay(this.date, this.focusedDuration);
}

List<FocusDay> getParsed() {
  if (_parsed != null) return _parsed!;
  return _parse();
}

List<FocusDay> _parse() {
  _parsed = <FocusDay>[];
  for (final row in _data) {
    _parsed!.add(FocusDay(stringToDate(row[0]), Duration(milliseconds: row[1])));
  }
  return _parsed!;
}