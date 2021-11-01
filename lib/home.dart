import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:stay_focused/data.dart';
import 'package:stay_focused/hosts.dart';
import 'package:stay_focused/strings.dart';

import 'main.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final Timer _uiUpdater;
  late final _player = AudioPlayer();

  bool get _isFocusing => preferences.containsKey(SESSION_START);
  int? get _startTimeMillis => preferences.getInt(SESSION_START);

  Duration _session = Duration.zero;
  Duration _today = Duration.zero;
  /// amount of focused time in previous sessions today
  Duration _todayPrev = Duration.zero;

  @override
  void initState() {
    super.initState();
    _uiUpdater = Timer.periodic(const Duration(seconds: 1), _updateUi);

    int? todayPrevMillis = getRow(dateString(DateTime.now()));
    if (todayPrevMillis != null) {
      _todayPrev = Duration(milliseconds: todayPrevMillis);
      _today = _todayPrev;
    }

    // call to update immediately without delay
    _updateUi(_uiUpdater);
  }

  @override
  void dispose() {
    _uiUpdater.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'This session: ${formatDuration(_session)}',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              'Today: ${formatDuration(_today)}',
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(height: 64.0),
            FloatingActionButton(
              child: Icon(
                _isFocusing ? Icons.remove_red_eye : Icons.remove_red_eye_outlined,
              ),
              onPressed: () {
                setState(() {
                  if (_isFocusing) {
                    _stopFocusing();
                  } else {
                    _startFocusing();
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateUi(Timer timer) {
    if (_startTimeMillis == null) return;
    setState(() {
      int elapsedMillis = DateTime.now().millisecondsSinceEpoch - _startTimeMillis!;
      _session = Duration(milliseconds: elapsedMillis);
      _today = _session + _todayPrev;
    });
    // play sound if over 1 hour
    if (_session > const Duration(hours: 1)) {
      _maybePlaySound();
    }
  }

  void _maybePlaySound() async {
    if (!_player.playing) {
      await _player.setAsset('assets/logos.mp3');
      _player.setLoopMode(LoopMode.all);
      _player.play();
    }
  }

  void _startFocusing() {
    // if already focused
    if (_isFocusing) return;

    preferences.setInt(SESSION_START, DateTime.now().millisecondsSinceEpoch);
    startBlocking();
  }

  void _stopFocusing() {
    if (!_isFocusing) return;

    preferences.remove(SESSION_START);
    // update time focused today
    writeRow(dateString(DateTime.now()), _today.inMilliseconds);
    _todayPrev = _today;
    stopBlocking();

    _player.stop();
  }
}
