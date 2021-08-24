import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart';

import 'colors.dart';
import 'data.dart';

class Stats extends StatelessWidget {
  const Stats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PastWeek(),
    );
  }
}

class PastWeek extends StatelessWidget {
  const PastWeek({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TimeSeriesChart(
      _buildLastWeek(),
    );
  }

  List<Series<FocusDay, DateTime>> _buildLastWeek() {
    final data = getParsed();

    return [
      Series<FocusDay, DateTime>(
        id: 'FocusDays',
        colorFn: (_, __) => Color(r: deusEx.red, g: deusEx.green, b: deusEx.blue),
        domainFn: (FocusDay day, _) => day.date,
        measureFn: (FocusDay day, _) => Duration(milliseconds: day.focusedTimeMillis).inSeconds / 3600,
        data: data,
      )
    ];
  }
}
