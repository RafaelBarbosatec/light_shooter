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

  int _currentIndex = 0;
  bool isFirstEvent = true;

  BufferDelay(this.delay, this._listen);

  void add(T value, DateTime time) {
    if (_timeLine.isEmpty) {
      if (isFirstEvent) {
        isFirstEvent = false;
        _timeLine.add(Delay(delay));
      }
      _timeLine.add(Frame<T>(value, time));
      run();
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
        int delay = delayLastFrame - delayDone;
        if (delay > 0) {
          if (delay > this.delay) {
            delay = this.delay;
          }
          _timeLine.add(Delay(delay));
        }
        _timeLine.add(Frame(value, time));
        verifyNext();
      }
    }
  }

  void reset() {
    Frame f = _timeLine.whereType<Frame>().last;
    if (f.timeRun != null) {
      _timeLine.clear();
      _currentIndex = 0;
    }
  }

  void run() async {
    if (_currentIndex < _timeLine.length) {
      var value = _timeLine[_currentIndex];
      if (value is Delay<T>) {
        await Future.delayed(Duration(milliseconds: value.time));
        verifyNext();
      } else if (value is Frame<T>) {
        value.timeRun = DateTime.now();
        _listen(value.value);
        verifyNext();
      }
    }
  }

  void verifyNext() {
    if ((_currentIndex + 1) < _timeLine.length) {
      _currentIndex++;
      run();
    }
  }
}
