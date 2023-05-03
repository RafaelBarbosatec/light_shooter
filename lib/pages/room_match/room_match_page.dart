import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:light_shooter/game/game.dart';
import 'package:light_shooter/game/game_route.dart';
import 'package:light_shooter/server_conection/server_client.dart';
import 'package:light_shooter/server_conection/websocket_client.dart';
import 'package:light_shooter/shared/bootstrap.dart';
// ignore: depend_on_referenced_packages
import 'package:nakama/nakama.dart';

class RoomMatchPage extends StatefulWidget {
  const RoomMatchPage({super.key});

  @override
  State<RoomMatchPage> createState() => _RoomMatchPageState();
}

class _RoomMatchPageState extends State<RoomMatchPage> {
  late WebsocketClient _websocketClient;
  late ServerClient _serverClient;
  StreamSubscription? onMatchmakerMatchedSubscription;
  MatchmakerTicket? matchmakerTicket;
  String userId = '';

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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (matchmakerTicket == null)
              ElevatedButton(
                onPressed: _createMatchMaker,
                child: const Text('Procurara partida'),
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
              const Text('Procurando players'),
            ]
          ],
        ),
      ),
    );
  }

  void _createMatchMaker() {
    _websocketClient.createMatchMaker().then((value) {
      setState(() {
        matchmakerTicket = value;
      });
    });
  }

  void _onMatchmaker(MatchmakerMatched event) {
    GameProperties properties = _getGameProperties(event);
    _websocketClient.joinMatch(event).then((value) {
      if (mounted) {
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
        );
      } else {
        opponentPositions.add(
          PlayerPropertie(
            userId: u.presence.userId,
            name: u.presence.username,
            position: positionsToBorn[index],
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
