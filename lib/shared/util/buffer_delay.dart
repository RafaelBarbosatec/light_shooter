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

  int get differenceTimeRun {
    if (timeRun != null) {
      return DateTime.now().difference(timeRun!).inMilliseconds;
    } else {
      return 0;
    }
  }
}

class BufferDelay<T> {
  static const maxItemTimeLine = 10;
  final int delay;
  final List<Timeline<T>> _timeLine = [];

  final ValueChanged<T> _listen;

  int _currentIndex = -1;
  bool running = false;

  BufferDelay(this.delay, this._listen);

  void add(T value, DateTime time) {
    if (_timeLine.isEmpty) {
      addTimeLine(Delay(delay));
      addTimeLine(Frame<T>(value, time));
    } else {
      Frame<T> lastFrame = _timeLine.last as Frame<T>;
      if (lastFrame.time.isBefore(time)) {
        int delayLastFrame = time.difference(lastFrame.time).inMilliseconds;
        if (lastFrame.timeRun == null) {
          if (delayLastFrame > 0) {
            addTimeLine(Delay(delayLastFrame));
          }
          addTimeLine(Frame(value, time));
        } else {
          int delayDone = lastFrame.differenceTimeRun;
          int delay = delayLastFrame - (delayDone + this.delay);
          if (delay > 0) {
            addTimeLine(Delay(delay > this.delay ? this.delay : delay));
          }
          addTimeLine(Frame(value, time));
        }
      }
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
    }
  }

  void addTimeLine(Timeline<T> timeline) {
    _timeLine.add(timeline);
    if (_timeLine.length > maxItemTimeLine) {
      _timeLine.removeAt(0);
      _currentIndex--;
    }
  }
}
