import 'package:flutter/material.dart';
import 'package:light_shooter/server_conection/server_client.dart';
import 'package:light_shooter/server_conection/websocket_client.dart';
import 'package:light_shooter/shared/bootstrap.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
          child: const Text('Entrar'),
        ),
      ),
    );
  }

  void _signIn() {
    _client.signIn().then((value) async {
       inject<WebsocketClient>().init(value);
      if (mounted) {
        Navigator.pushNamed(context, '/roomMatch');
      }
    });
  }
}
