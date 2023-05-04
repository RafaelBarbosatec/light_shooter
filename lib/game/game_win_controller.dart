import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:light_shooter/server_conection/server_client.dart';

class GameWinController extends GameComponent {
  bool finishedGame = false;
  final ServerClient _serverClient;

  GameWinController(this._serverClient);
  @override
  void update(double dt) {
    if (checkInterval('CHECK_WIN', 250, dt) && !finishedGame) {
      _verifyWinOrLose();
    }
    super.update(dt);
  }

  void _verifyWinOrLose() {
    if (gameRef.player?.isDead == true) {
      _showGameOver(gameRef.context);
      finishedGame = true;
    }
    if (gameRef.livingEnemies().isEmpty) {
      _showWin(gameRef.context);
      finishedGame = true;
    }
  }

  void _showGameOver(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: const Text('Não desanime vamos ao treino!'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, false);
              },
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }

  void _showWin(BuildContext context) {
    _serverClient.addLeaderboardScore(2);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Parabens!!!!'),
          content: const Text('Você venceu a batalha'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }
}
