import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:light_shooter/game/game.dart';
import 'package:light_shooter/game/game_route.dart';
import 'package:light_shooter/game/util/player_customization.dart';
import 'package:light_shooter/game/util/player_spritesheet.dart';
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

  PlayerCustomization playerCustomization = const PlayerCustomization(
    color: PlayerColor.green,
  );
  @override
  void initState() {
    _websocketClient = inject();
    _serverClient = inject();
    onMatchmakerMatchedSubscription =
        _websocketClient.listenMatchmaker().listen(_onMatchmaker);
    userId = _serverClient.getSession().userId;
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
            Center(
              child: FutureBuilder<Account?>(
                future: _serverClient.getAccount(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.all(54.0),
                      child: Text(
                        'Hello ${snapshot.data?.user.username}!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            Center(
              child: GameContainer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (matchmakerTicket == null)
                      GameButton(
                        onPressed: _createMatchMaker,
                        text: 'Find game',
                      )
                    else ...[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 10),
                      Text(
                        'Ticket: ${matchmakerTicket!.ticket}',
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Looking for players'),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _cancelMatchMaker,
                        child: const Text('Cancel'),
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

  void _cancelMatchMaker() async {
    await _websocketClient.exitMatchmaker();
    setState(() {
      matchmakerTicket = null;
    });
  }

  void _createMatchMaker() {
    _websocketClient
        .createMatchMaker(propertiers: playerCustomization.toMap())
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
        _cancelMatchMaker();
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
