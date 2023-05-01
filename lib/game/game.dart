import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:light_shooter/game/player/breaker.dart';
import 'package:light_shooter/game/remote_player/remote_breaker.dart';
import 'package:light_shooter/server_conection/server_client.dart';
import 'package:light_shooter/server_conection/websocket_client.dart';
import 'package:light_shooter/shared/bootstrap.dart';
// ignore: depend_on_referenced_packages
import 'package:nakama/nakama.dart';

class Game extends StatefulWidget {
  const Game({Key? key}) : super(key: key);

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  late WebsocketClient _websocketClient;
  late ServerClient _serverClient;
  @override
  void initState() {
    _serverClient = inject();
    _websocketClient = inject();
    _websocketClient.addOnMatchPresenceObserser(_onMatchPresence);

    super.initState();
  }

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
      player: Breaker(
        id: _serverClient.getSession().userId,
        position: Vector2.all(96),
        websocketClient: _websocketClient,
      ),
      cameraConfig: CameraConfig(
        zoom: 1.5,
        smoothCameraEnabled: true,
        smoothCameraSpeed: 3.0,
      ),
      onReady: _onReady,
      onDispose: () => _websocketClient.leaveMatch(),
    );
  }

  _onMatchPresence(MatchPresenceEvent data) {
    print(data.toString());
  }

  void _onReady(BonfireGame game) {
    for (var element
        in (_websocketClient.getMatch() as RealtimeMatch).presences) {
      game.add(
        RemoteBreaker(
          id: element.userId,
          websocketClient: _websocketClient,
          position: Vector2.all(96),
        ),
      );
    }
  }
}
