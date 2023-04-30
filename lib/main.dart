import 'package:flutter/material.dart';
import 'package:light_shooter/game/game.dart';
import 'package:light_shooter/pages/home_page.dart';
import 'package:light_shooter/pages/room_match_page.dart';
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
        '/': (context) => const HomePage(),
        '/game': (context) => const Game(),
        '/roomMatch': (context) => const RoomMatchPage(),
      },
    );
  }
}
