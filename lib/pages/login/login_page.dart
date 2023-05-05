import 'package:flutter/material.dart';
import 'package:light_shooter/pages/home/home_route.dart';
import 'package:light_shooter/pages/room_match/room_match_route.dart';
import 'package:light_shooter/server_conection/server_client.dart';
import 'package:light_shooter/server_conection/websocket_client.dart';
import 'package:light_shooter/shared/bootstrap.dart';
import 'package:light_shooter/shared/theme/game_colors.dart';
import 'package:light_shooter/shared/widgets/game_button.dart';
import 'package:light_shooter/shared/widgets/game_container.dart';

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
      backgroundColor: GameColors.background,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Light Shooter',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                GameContainer(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GameButton(
                        expanded: true,
                        onPressed: _signIn,
                        text: 'Sign in',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Buit with Bonfire',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _signIn() {
    _client.signInDevice().then((value) async {
      inject<WebsocketClient>().init(value);
      if (mounted) {
        HomeRoute.open(context);
      }
    });
  }
}
