import 'dart:math';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart';
import 'package:table_calendar/table_calendar.dart';

import 'colors.dart';
import 'data.dart';

class Stats extends StatelessWidget {
  const Stats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Column(
              children: [
                Expanded(child: PastWeek()),
                Expanded(child: PastMonth()),
              ],
            ),
          ),
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Weekly average: ${_getAverage(7).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  Text(
                    'Monthly average: ${_getAverage(30).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  Text(
                    'All time average: ${_getAverage().toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  Calendar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChartContainer extends StatelessWidget {
  final String title;
  final Widget chart;

  const ChartContainer({Key? key, required this.title, required this.chart})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headline5,
          ),
          Expanded(child: chart),
        ],
      ),
    );
  }
}

List<Series<FocusDay, DateTime>> _buildSeries(int days) {
  final allTime = getParsed();
  if (allTime.isEmpty) return [];
  final truncated = allTime.getRange(max(0, allTime.length - days), allTime.length);

  return [
    Series<FocusDay, DateTime>(
      id: 'FocusDays',
      colorFn: (_, __) => Color(r: deusEx.red, g: deusEx.green, b: deusEx.blue),
      domainFn: (FocusDay day, _) => day.date,
      measureFn: (FocusDay day, _) =>
          Duration(milliseconds: day.focusedTimeMillis).inSeconds / 3600,
      data: truncated.toList(),
    )
  ];
}

double _getAverage([int? days]) {
  final allTime = getParsed();
  if (allTime.isEmpty) return 0.0;
  if (days == null) days = allTime.length;
  final truncated = allTime.getRange(max(0, allTime.length - days), allTime.length);
  final totalMillis = truncated
      .map<int>((day) => day.focusedTimeMillis)
      .reduce((value, element) => value + element);
  final totalHours = Duration(milliseconds: totalMillis).inSeconds / 3600;
  return totalHours / days;
}

class PastWeek extends StatelessWidget {
  const PastWeek({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChartContainer(
      title: 'Last Week',
      chart: TimeSeriesChart(
        _buildSeries(7),
      ),
    );
  }
}

class PastMonth extends StatelessWidget {
  const PastMonth({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChartContainer(
      title: 'Last Month',
      chart: TimeSeriesChart(
        _buildSeries(30),
      ),
    );
  }
}

class Calendar extends StatelessWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final allDates = getParsed();
    // TODO this will probably throw if empty
    return TableCalendar(
      firstDay: allDates.first.date,
      lastDay: allDates.last.date,
      focusedDay: allDates.last.date,
      // calendarBuilders: CalendarBuilders(
      //   defaultBuilder: (context, day, focusedDay) => Text('lol'),
      // ),
    );
  }
}
