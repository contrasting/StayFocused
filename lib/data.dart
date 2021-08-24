import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stay_focused/strings.dart';

late final File _file;
late final List<List<dynamic>> _data;
List<FocusDay>? _parsed;

// call this before using any other methods
Future<void> loadData() async {
  final documents = await getApplicationDocumentsDirectory();
  _file = File('${documents.path}/focus_data.csv');
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
  final int focusedTimeMillis;

  FocusDay(this.date, this.focusedTimeMillis);
}

List<FocusDay> getParsed() {
  if (_parsed != null) return _parsed!;
  return _parse();
}

List<FocusDay> _parse() {
  _parsed = <FocusDay>[];
  for (final row in _data) {
    _parsed!.add(FocusDay(stringToDate(row[0]), row[1]));
  }
  return _parsed!;
}