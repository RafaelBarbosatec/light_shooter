import 'package:flutter/material.dart';
import 'package:light_shooter/shared/theme/game_colors.dart';

class GameButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool expanded;
  const GameButton(
      {super.key, this.onPressed, required this.text, this.expanded = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expanded ? double.maxFinite : null,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: const ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(GameColors.primary),
          shape: MaterialStatePropertyAll(StadiumBorder()),
        ),
        child: Text(text),
      ),
    );
  }
}
