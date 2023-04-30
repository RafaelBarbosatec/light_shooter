import 'dart:async';

import 'package:flutter/material.dart';
import 'package:light_shooter/server_conection/websocket_client.dart';
import 'package:light_shooter/shared/bootstrap.dart';
import 'package:nakama/rtapi.dart' as rt;

class RoomMatchPage extends StatefulWidget {
  const RoomMatchPage({super.key});

  @override
  State<RoomMatchPage> createState() => _RoomMatchPageState();
}

class _RoomMatchPageState extends State<RoomMatchPage> {
  late WebsocketClient _websocketClient;
  StreamSubscription? onMatchmakerMatchedSubscription;
  rt.MatchmakerTicket? matchmakerTicket;
  @override
  void initState() {
    _websocketClient = inject();
    onMatchmakerMatchedSubscription =
        _websocketClient.listenMatchmaker().listen(_onMatchmaker);
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
              Text('Ticket: ${matchmakerTicket!.ticket}'),
              Text(matchmakerTicket!.ticket),
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

  void _onMatchmaker(rt.MatchmakerMatched event) {
    _websocketClient.joinMatch(event).then((value) {
      if (mounted) {
        Navigator.pushNamed(context, '/game');
      }
    });
  }

  void _disposeStream() async {
    await onMatchmakerMatchedSubscription?.cancel();
  }
}
