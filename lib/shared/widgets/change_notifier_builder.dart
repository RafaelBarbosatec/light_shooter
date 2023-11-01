import 'package:flutter/material.dart';

class ChangeNotifierBuilder<T extends ChangeNotifier> extends StatelessWidget {
  const ChangeNotifierBuilder({
    Key? key,
    required this.value,
    required this.builder,
  }) : super(key: key);

  final T value;
  final Widget Function(BuildContext context, T value) builder;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: value,
      builder: (context, child) {
        return builder(context, value);
      },
    );
  }
}
