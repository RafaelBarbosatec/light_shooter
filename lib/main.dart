import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:light_shooter/player/breaker.dart';

void main() {
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
      home: const Game(),
    );
  }
}

class Game extends StatelessWidget {
  const Game({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BonfireWidget(
      joystick: Joystick(
        keyboardConfig: KeyboardConfig(),
        directional: JoystickDirectional(),
        actions: [
          JoystickAction(
            actionId: 1,
            margin: const EdgeInsets.all(50),
            enableDirection: true,
          ),
          JoystickAction(
            actionId: 2,
            margin:
                const EdgeInsets.all(50) + const EdgeInsets.only(right: 100),
            color: Colors.yellow,
          ),
        ],
      ),
      map: WorldMapByTiled('maps/map1.tmj'),
      player: Breaker(position: Vector2.all(96)),
      cameraConfig: CameraConfig(
        zoom: 1.5,
        smoothCameraEnabled: true,
        smoothCameraSpeed: 3.0,
      ),
    );
  }
}
