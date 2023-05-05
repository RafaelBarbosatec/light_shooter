import 'package:flutter/material.dart';
import 'package:light_shooter/shared/widgets/game_button.dart';
import 'package:light_shooter/shared/widgets/game_container.dart';

enum GameDialogTypeEnum { win, gameOver }

class GameDialog extends StatelessWidget {
  final GameDialogTypeEnum type;
  final VoidCallback? onTapOk;
  const GameDialog({super.key, required this.type, this.onTapOk});

  static Future show(BuildContext context, GameDialogTypeEnum type,
      {VoidCallback? onTapOk}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return GameDialog(
          type: type,
          onTapOk: onTapOk,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: GameContainer(
          margin: const EdgeInsets.all(24),
          constraints: const BoxConstraints(
            maxWidth: 400,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Icon(
                _getIcon(type),
                size: 100,
                color: _getIconColor(type),
              ),
              const SizedBox(height: 8),
              Text(
                _getTile(type),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              GameButton(
                expanded: true,
                text: 'OK',
                onPressed: () {
                  Navigator.pop(context);
                  onTapOk?.call();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTile(GameDialogTypeEnum type) {
    switch (type) {
      case GameDialogTypeEnum.win:
        return 'Congratulations';
      case GameDialogTypeEnum.gameOver:
        return 'Game Over';
    }
  }

  IconData? _getIcon(GameDialogTypeEnum type) {
    switch (type) {
      case GameDialogTypeEnum.win:
        return Icons.emoji_events_sharp;
      case GameDialogTypeEnum.gameOver:
        return Icons.sentiment_dissatisfied_rounded;
    }
  }

  Color? _getIconColor(GameDialogTypeEnum type) {
    switch (type) {
      case GameDialogTypeEnum.win:
        return Colors.yellow[700];
      case GameDialogTypeEnum.gameOver:
        return Colors.red;
    }
  }
}
