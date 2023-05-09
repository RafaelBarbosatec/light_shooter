// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:light_shooter/game/game_win_controller.dart';
import 'package:light_shooter/game/interface/bar_life.dart';
import 'package:light_shooter/game/player/breaker.dart';
import 'package:light_shooter/game/remote_player/remote_breaker.dart';
import 'package:light_shooter/game/util/player_customization.dart';
import 'package:light_shooter/server_conection/server_client.dart';
import 'package:light_shooter/server_conection/websocket_client.dart';
import 'package:light_shooter/shared/bootstrap.dart';
// ignore: depend_on_referenced_packages
import 'package:nakama/nakama.dart';

class PlayerPropertie {
  String userId;
  String name;
  Vector2 position;
  final PlayerCustomization customization;
  PlayerPropertie({
    required this.userId,
    required this.position,
    this.name = '',
    this.customization = const PlayerCustomization(),
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
  static const tileSize = 32.0;
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
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: BonfireWidget(
        joystick: Joystick(
          keyboardConfig: KeyboardConfig(
            keyboardDirectionalType: KeyboardDirectionalType.wasdAndArrows,
          ),
        ),
        overlayBuilderMap: {
          BarLife.name: (context, game) => BarLife(game: game),
        },
        initialActiveOverlays: [
          BarLife.name,
        ],
        map: WorldMapByTiled('maps/map1.tmj'),
        player: Breaker(
          position: widget.properties.myProperties.position * Game.tileSize,
          color: widget.properties.myProperties.customization.color,
          name: widget.properties.myProperties.name,
          websocketClient: _websocketClient,
        ),
        cameraConfig: CameraConfig(
          zoom: 1.5,
          smoothCameraEnabled: true,
          smoothCameraSpeed: 3.0,
        ),
        onReady: _onReady,
        onDispose: () => _websocketClient.leaveMatch(),
        components: [GameWinController()],
      ),
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
          position: element.position * Game.tileSize,
          color: element.customization.color,
          name: element.name,
        ),
      );
    }
  }
}
