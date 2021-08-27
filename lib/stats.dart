import 'dart:math';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart';
import 'package:table_calendar/table_calendar.dart';

import 'colors.dart';
import 'data.dart';
import 'strings.dart';

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
                Expanded(child: FocusChart(title: 'Last Week', observations: 7)),
                Expanded(child: FocusChart(title: 'Last Month', observations: 30)),
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
                    'Weekly total: ${formatDurationNoSecs(_getTotal(7))}',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  Text(
                    'Monthly total: ${formatDurationNoSecs(_getTotal(30))}',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Weekly average: ${formatDurationNoSecs(_getAverage(7))}',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  Text(
                    'Monthly average: ${formatDurationNoSecs(_getAverage(30))}',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  Text(
                    'All time average: ${formatDurationNoSecs(_getAverage())}',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  Spacer(),
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
  final String? subtitle;
  final Widget chart;

  const ChartContainer({Key? key, required this.title, required this.chart, this.subtitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headline5,
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.headline6,
                ),
            ],
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
      measureFn: (FocusDay day, _) => day.focusedDuration.inSeconds / 3600,
      data: truncated.toList(),
    )
  ];
}

Duration _getAverage([int? days]) {
  final allTime = getParsed();
  if (allTime.isEmpty) return Duration.zero;
  if (days == null) days = allTime.length;
  final truncated = allTime.getRange(max(0, allTime.length - days), allTime.length);
  final total = truncated
      .map<Duration>((day) => day.focusedDuration)
      .reduce((value, element) => value + element);
  return total ~/ days;
}

Duration _getTotal([int? days]) {
  final allTime = getParsed();
  if (allTime.isEmpty) return Duration.zero;
  if (days == null) days = allTime.length;
  final truncated = allTime.getRange(max(0, allTime.length - days), allTime.length);
  final total = truncated
      .map<Duration>((day) => day.focusedDuration)
      .reduce((value, element) => value + element);
  return total;
}

class FocusChart extends StatefulWidget {
  final String title;
  final int observations;

  const FocusChart({Key? key, required this.title, required this.observations}) : super(key: key);

  @override
  _FocusChartState createState() => _FocusChartState();
}

class _FocusChartState extends State<FocusChart> {
  String? _subtitle;

  @override
  Widget build(BuildContext context) {
    return ChartContainer(
      title: widget.title,
      subtitle: _subtitle,
      chart: TimeSeriesChart(
        _buildSeries(widget.observations),
        // https://google.github.io/charts/flutter/example/behaviors/selection_callback_example
        selectionModels: [
          SelectionModelConfig(
            type: SelectionModelType.info,
            changedListener: (model) {
              final selectedDatum = model.selectedDatum;
              if (selectedDatum.isNotEmpty) {
                FocusDay day = selectedDatum.first.datum;
                setState(() {
                  _subtitle = formatDurationNoSecs(day.focusedDuration);
                });
              }
            }
          ),
        ],
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
    final allDatesMap = Map<String, Duration>.fromIterable(
      allDates,
      key: (day) => dateString(day.date),
      value: (day) => day.focusedDuration,
    );
    return TableCalendar(
      firstDay: allDates.first.date,
      lastDay: allDates.last.date,
      focusedDay: allDates.last.date,
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          return _buildDay(allDatesMap, day);
        },
        todayBuilder: (context, day, focusedDay) {
          return _buildDay(allDatesMap, day);
        }
      ),
    );
  }

  Widget _buildDay(Map<String, Duration> allDatesMap, DateTime day) {
    final date = dateString(day);
    if (allDatesMap[date] == null) return Text('ERROR');
    return Center(child: Text(formatDurationNoSecs(allDatesMap[date]!)));
  }
}
