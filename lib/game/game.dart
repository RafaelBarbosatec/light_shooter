// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:light_shooter/game/player/breaker.dart';
import 'package:light_shooter/game/remote_player/remote_breaker.dart';
import 'package:light_shooter/server_conection/server_client.dart';
import 'package:light_shooter/server_conection/websocket_client.dart';
import 'package:light_shooter/shared/bootstrap.dart';
// ignore: depend_on_referenced_packages
import 'package:nakama/nakama.dart';

class PlayerPropertie {
  String userId;
  String name;
  Vector2 position;
  String skin;
  PlayerPropertie({
    required this.userId,
    required this.position,
    this.name = '',
    this.skin = '',
  });
}

class GameProperties {
  final PlayerPropertie myProperties;
  final List<PlayerPropertie> opponentPositions;
  GameProperties({
    required this.myProperties,
    required this.opponentPositions,
  });
}

class Game extends StatefulWidget {
  final GameProperties properties;
  const Game({Key? key, required this.properties}) : super(key: key);

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  late WebsocketClient _websocketClient;
  late ServerClient _serverClient;
  BonfireGame? game;
  String userId = '';
  @override
  void initState() {
    _serverClient = inject();
    _websocketClient = inject();
    userId = _serverClient.getSession().userId;
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
        position: widget.properties.myProperties.position * 32,
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

  void _onMatchPresence(MatchPresenceEvent data) {
    if (game != null) {
      for (var leave in data.leaves) {
        game!
            .componentsByType<RemoteBreaker>()
            .where((element) => element.id == leave.userId)
            .forEach((remote) => remote.removeFromParent());
      }
    }
  }

  void _onReady(BonfireGame game) {
    this.game = game;
    for (var element in widget.properties.opponentPositions) {
      game.add(
        RemoteBreaker(
          id: element.userId,
          websocketClient: _websocketClient,
          position: element.position * 32,
        ),
      );
    }
  }
}
