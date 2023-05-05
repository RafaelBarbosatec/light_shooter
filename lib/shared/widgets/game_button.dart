import 'package:flutter/material.dart';
import 'package:light_shooter/shared/theme/game_colors.dart';

class GameButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool expanded;
  final bool loading;
  const GameButton({
    super.key,
    this.onPressed,
    required this.text,
    this.expanded = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (expanded ? double.maxFinite : null),
      height: 40,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: const ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(GameColors.primary),
          shape: MaterialStatePropertyAll(StadiumBorder()),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(
                  text,
                  style: const TextStyle(color: Colors.white),
                ),
        ),
      ),
    );
  }
}
