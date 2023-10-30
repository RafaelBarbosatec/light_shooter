import 'package:flutter/material.dart';
import 'package:light_shooter/game/game.dart';

class GameRoute {
  static const name = '/game';

  static Map<String, WidgetBuilder> get builder => {
        name: (context) => Game(
              properties:
                  ModalRoute.of(context)?.settings.arguments as GameProperties,
            ),
      };

  static Future open(BuildContext context, GameProperties properties) {
    return Navigator.of(context).pushNamed(name, arguments: properties);
  }
}
