// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:light_shooter/game/decorations/poison.dart';
import 'package:light_shooter/game/game_win_controller.dart';
import 'package:light_shooter/game/interface/bar_life.dart';
import 'package:light_shooter/game/player/breaker.dart';
import 'package:light_shooter/game/remote_player/remote_breaker.dart';
import 'package:light_shooter/game/util/player_customization.dart';
import 'package:light_shooter/server_conection/modules/nakama_websocket.dart';
import 'package:light_shooter/server_conection/nakama_service.dart';
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
  final bool enabledMouse;
  const Game({
    Key? key,
    required this.properties,
    this.enabledMouse = false,
  }) : super(key: key);

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  late NakamaWebsocket _websocketClient;
  late NakamaService _serverClient;
  BonfireGameInterface? game;
  String userId = '';
  @override
  void initState() {
    _serverClient = inject();
    _websocketClient = _serverClient.websocket();
    userId = _serverClient.auth().getSession().userId;
    _websocketClient.addOnMatchPresenceObserser(_onMatchPresence);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: BonfireWidget(
        joystick: Joystick(
          keyboardConfig: KeyboardConfig(),
          directional: widget.enabledMouse
              ? null
              : JoystickDirectional(
                  isFixed: false,
                  size: 100,
                ),
          actions: widget.enabledMouse
              ? []
              : [
                  JoystickAction(
                    actionId: 1,
                    enableDirection: true,
                    margin: const EdgeInsets.all(80),
                    size: 60,
                  ),
                ],
        ),
        overlayBuilderMap: {
          BarLife.name: (context, game) => BarLife(game: game),
        },
        initialActiveOverlays: [
          BarLife.name,
        ],
        map: WorldMapByTiled(
          'maps/map1.tmj',
          objectsBuilder: {
            Poison.name: (prop) => Poison(prop.position, prop.size)
          },
        ),
        player: Breaker(
          position: widget.properties.myProperties.position * Game.tileSize,
          color: widget.properties.myProperties.customization.color,
          name: widget.properties.myProperties.name,
          websocketClient: _websocketClient,
          enabledMouse: widget.enabledMouse,
        ),
        cameraConfig: CameraConfig(
          zoom: getZoomFromMaxVisibleTile(context, 20, 30),
        ),
        onReady: _onReady,
        onDispose: () => _websocketClient.leaveMatch(),
        components: [
          GameWinController(),
        ],
      ),
    );
  }

  void _onMatchPresence(MatchPresenceEvent data) {
    for (var leave in data.leaves) {
      game
          ?.query<RemoteBreaker>()
          .where((element) => element.id == leave.userId)
          .forEach((remote) => remote.removeFromParent());
    }
  }

  void _onReady(BonfireGameInterface game) {
    this.game = game;
    for (var e in widget.properties.opponentPositions) {
      game.add(
        RemoteBreaker(
          id: e.userId,
          position: e.position * Game.tileSize,
          color: e.customization.color,
          name: e.name,
          websocket: _websocketClient,
        ),
      );
    }
  }
}
