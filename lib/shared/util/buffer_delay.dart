import 'package:flutter/widgets.dart';

abstract class Timeline<T> {}

class Delay<T> extends Timeline<T> {
  final int time;

  Delay(this.time);
}

class Frame<T> extends Timeline<T> {
  final T value;
  final DateTime time;
  DateTime? timeRun;

  Frame(this.value, this.time);
}

class BufferDelay<T> {
  final int delay;
  final List<Timeline<T>> _timeLine = [];

  final ValueChanged<T> _listen;

  int _currentIndex = -1;
  bool running = false;

  BufferDelay(this.delay, this._listen);

  void add(T value, DateTime time) {
    if (_timeLine.isEmpty) {
      _timeLine.add(Delay(delay));
      _timeLine.add(Frame<T>(value, time));
    } else {
      Frame<T> lastFrame = _timeLine.last as Frame<T>;
      int delayLastFrame = time.difference(lastFrame.time).inMilliseconds;
      if (lastFrame.timeRun == null) {
        if (delayLastFrame > 0) {
          _timeLine.add(Delay(delayLastFrame));
        }
        _timeLine.add(Frame(value, time));
      } else {
        int delayDone =
            DateTime.now().difference(lastFrame.timeRun!).inMilliseconds;
        int delay = delayLastFrame - (delayDone + this.delay);
        if (delay > 0) {
          _timeLine.add(Delay(delay > this.delay ? this.delay : delay));
        }
        _timeLine.add(Frame(value, time));
      }
    }
  }

  void reset() {
    Frame f = _timeLine.whereType<Frame>().last;
    if (f.timeRun != null) {
      _timeLine.clear();
      _currentIndex = -1;
    }
  }

  void run() async {
    if ((_currentIndex + 1) < _timeLine.length && !running) {
      running = true;
      _currentIndex++;
      var value = _timeLine[_currentIndex];
      if (value is Delay<T>) {
        await Future.delayed(Duration(milliseconds: value.time));
      } else if (value is Frame<T>) {
        value.timeRun = DateTime.now();
        _listen(value.value);
      }
      running = false;
    } else {
      _removeUtilRestFive();
    }
  }

  void _removeUtilRestFive() {
    if (_timeLine.length > 10) {
      var diff = _timeLine.length - 10;
      List.generate(diff, (index) {
        _timeLine.removeAt(0);
        _currentIndex--;
      });
    }
  }
}
