import 'package:flutter/material.dart';

class ChangeNotifierBuilder<T extends ChangeNotifier> extends StatefulWidget {
  const ChangeNotifierBuilder({
    Key? key,
    required this.value,
    required this.builder,
  }) : super(key: key);

  final T value;

  final Widget Function(BuildContext context, T value) builder;

  @override
  ChangeNotifierBuilderState<T> createState() =>
      ChangeNotifierBuilderState<T>();
}

class ChangeNotifierBuilderState<T extends ChangeNotifier>
    extends State<ChangeNotifierBuilder<T>> {
  @override
  void initState() {
    widget.value.addListener(_listener);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ChangeNotifierBuilder<T> oldWidget) {
    if (widget.value != oldWidget.value) {
      _miggrate(widget.value, oldWidget.value, _listener);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.value.removeListener(_listener);
    super.dispose();
  }

  void _miggrate(Listenable a, Listenable b, void Function() listener) {
    a.removeListener(listener);
    b.addListener(listener);
  }

  void _listener() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.value);
  }
}
