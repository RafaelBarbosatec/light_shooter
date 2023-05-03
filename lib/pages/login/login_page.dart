import 'package:flutter/material.dart';
import 'package:light_shooter/pages/room_match/room_match_route.dart';
import 'package:light_shooter/server_conection/server_client.dart';
import 'package:light_shooter/server_conection/websocket_client.dart';
import 'package:light_shooter/shared/bootstrap.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late ServerClient _client;
  @override
  void initState() {
    _client = inject();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _signIn,
          child: const Text('Enter'),
        ),
      ),
    );
  }

  void _signIn() {
    _client.signInDevice().then((value) async {
      inject<WebsocketClient>().init(value);
      if (mounted) {
        RoomMatchRoute.open(context);
      }
    });
  }
}
