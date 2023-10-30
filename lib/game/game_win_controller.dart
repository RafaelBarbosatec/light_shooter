import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:light_shooter/pages/home/home_route.dart';
import 'package:light_shooter/shared/widgets/game_dialog.dart';

class GameWinController extends GameComponent {
  bool finishedGame = false;
  bool checking = false;

  @override
  void onMount() {
    Future.delayed(const Duration(seconds: 1), () {
      checking = true;
    });
    super.onMount();
  }

  @override
  void update(double dt) {
    // if (checkInterval('CHECK_WIN', 250, dt) && !finishedGame && checking) {
    //   _verifyWinOrLose();
    // }
    super.update(dt);
  }

  void _verifyWinOrLose() {
    if (gameRef.player?.isDead == true) {
      _showDialog(gameRef.context, GameDialogTypeEnum.gameOver);
      finishedGame = true;
    }
    if (gameRef.livingEnemies().isEmpty) {
      _showDialog(gameRef.context, GameDialogTypeEnum.win);
      finishedGame = true;
    }
  }

  void _showDialog(BuildContext context, GameDialogTypeEnum type) {
    GameDialog.show(
      context,
      type,
      onTapOk: () {
        Navigator.popUntil(
          context,
          (route) => route.settings.name == HomeRoute.name,
        );
      },
    );
  }
}
