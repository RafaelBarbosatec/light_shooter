import 'package:flutter/material.dart';
import 'package:light_shooter/game/util/player_customization.dart';
import 'package:light_shooter/pages/room_match/room_match_page.dart';

class RoomMatchRoute {
  static const name = '/roomMatch';

  static Map<String, WidgetBuilder> get builder => {
        name: (context) => RoomMatchPage(
              custom: ModalRoute.of(context)?.settings.arguments
                  as PlayerCustomization,
            ),
      };

  static Future open(BuildContext context, PlayerCustomization custom) {
    return Navigator.of(context).pushNamed(name, arguments: custom);
  }
}
