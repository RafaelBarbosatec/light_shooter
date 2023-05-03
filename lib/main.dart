import 'package:flutter/material.dart';
import 'package:light_shooter/game/game_route.dart';
import 'package:light_shooter/pages/login/login_route.dart';
import 'package:light_shooter/pages/room_match/room_match_route.dart';
import 'package:light_shooter/shared/bootstrap.dart';

void main() {
  Bootstrap.run();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Light Shooter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        ...LoginRoute.builder,
        ...GameRoute.builder,
        ...RoomMatchRoute.builder,
      },
    );
  }
}
