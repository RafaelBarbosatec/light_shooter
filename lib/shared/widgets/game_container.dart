import 'package:flutter/material.dart';
import 'package:light_shooter/shared/theme/game_colors.dart';

class GameContainer extends StatelessWidget {
  final Widget child;
  final BoxConstraints? constraints;
  const GameContainer({super.key, required this.child, this.constraints});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: constraints,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GameColors.secondary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}
