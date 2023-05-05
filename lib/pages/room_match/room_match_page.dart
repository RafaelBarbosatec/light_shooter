import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:light_shooter/game/game.dart';
import 'package:light_shooter/game/game_route.dart';
import 'package:light_shooter/game/util/player_customization.dart';
import 'package:light_shooter/server_conection/server_client.dart';
import 'package:light_shooter/server_conection/websocket_client.dart';
import 'package:light_shooter/shared/bootstrap.dart';
import 'package:light_shooter/shared/theme/game_colors.dart';
import 'package:light_shooter/shared/widgets/game_button.dart';
import 'package:light_shooter/shared/widgets/game_container.dart';
// ignore: depend_on_referenced_packages
import 'package:nakama/nakama.dart';

class RoomMatchPage extends StatefulWidget {
  final PlayerCustomization custom;
  const RoomMatchPage({super.key, required this.custom});

  @override
  State<RoomMatchPage> createState() => _RoomMatchPageState();
}

class _RoomMatchPageState extends State<RoomMatchPage> {
  late WebsocketClient _websocketClient;
  late ServerClient _serverClient;
  StreamSubscription? onMatchmakerMatchedSubscription;
  MatchmakerTicket? matchmakerTicket;
  String userId = '';
  String userName = '';

  List<Vector2> positionsToBorn = [
    Vector2(3, 3),
    Vector2(8, 15),
    Vector2(15, 3),
  ];

  @override
  void initState() {
    _websocketClient = inject();
    _serverClient = inject();
    onMatchmakerMatchedSubscription =
        _websocketClient.listenMatchmaker().listen(_onMatchmaker);
    userId = _serverClient.getSession().userId;
    Future.delayed(Duration.zero, _createMatchMaker);
    super.initState();
  }

  @override
  void dispose() {
    _websocketClient.exitMatchmaker();
    _disposeStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Center(
              child: Text(
                'Looking for players',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: GameContainer(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (matchmakerTicket != null) ...[
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          GameColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ticket:',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        matchmakerTicket!.ticket,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                      GameButton(
                        expanded: true,
                        onPressed: _cancelMatchMaker,
                        text: 'Cancel',
                      )
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _cancelMatchMaker({bool backScreen = true}) async {
    await _websocketClient.exitMatchmaker();
    if (mounted && backScreen) {
      Navigator.pop(context);
    }
  }

  void _createMatchMaker() {
    _websocketClient
        .createMatchMaker(propertiers: widget.custom.toMap())
        .then((value) {
      setState(() {
        matchmakerTicket = value;
      });
    });
  }

  void _onMatchmaker(MatchmakerMatched event) {
    GameProperties properties = _getGameProperties(event);
    _websocketClient.joinMatch(event).then((value) {
      if (mounted) {
        _cancelMatchMaker(backScreen: false);
        GameRoute.open(context, properties);
      }
    });
  }

  void _disposeStream() async {
    await onMatchmakerMatchedSubscription?.cancel();
  }

  GameProperties _getGameProperties(MatchmakerMatched event) {
    List<MatchmakerUser> users = event.users.toList();
    PlayerPropertie myProperties = PlayerPropertie(
      position: Vector2.zero(),
      userId: '',
    );
    List<PlayerPropertie> opponentPositions = [];

    users.sort(
      (a, b) {
        double firstNumber =
            a.numericProperties[WebsocketClient.PARAM_NUMBER_POSITION] ?? 0.0;
        double secondNumber =
            b.numericProperties[WebsocketClient.PARAM_NUMBER_POSITION] ?? 0.0;
        return firstNumber.compareTo(secondNumber);
      },
    );

    int index = 0;
    for (var u in users) {
      if (u.presence.userId == userId) {
        myProperties = PlayerPropertie(
          userId: u.presence.userId,
          name: u.presence.username,
          position: positionsToBorn[index],
          customization: PlayerCustomization.fromMap(u.stringProperties),
        );
      } else {
        opponentPositions.add(
          PlayerPropertie(
            userId: u.presence.userId,
            name: u.presence.username,
            position: positionsToBorn[index],
            customization: PlayerCustomization.fromMap(u.stringProperties),
          ),
        );
      }
      index++;
    }

    return GameProperties(
      myProperties: myProperties,
      opponentPositions: opponentPositions,
    );
  }
}
