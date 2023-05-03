import 'package:flutter/material.dart';
import 'package:light_shooter/pages/room_match/room_match_page.dart';

class RoomMatchRoute {
  static const name = '/roomMatch';

  static Map<String, WidgetBuilder> get builder => {
        name: (context) => const RoomMatchPage(),
      };

  static Future open(BuildContext context) {
    return Navigator.of(context).pushNamed(name);
  }
}
