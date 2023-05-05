import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:light_shooter/game/util/player_spritesheet.dart';
import 'package:light_shooter/pages/room_match/room_match_route.dart';
import 'package:light_shooter/server_conection/server_client.dart';
import 'package:light_shooter/shared/bootstrap.dart';
import 'package:light_shooter/shared/theme/game_colors.dart';
import 'package:light_shooter/shared/widgets/game_button.dart';
import 'package:light_shooter/shared/widgets/game_container.dart';
// ignore: depend_on_referenced_packages
import 'package:nakama/nakama.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ServerClient _serverClient;
  @override
  void initState() {
    _serverClient = inject();
    super.initState();
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
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 4),
                child: GameContainer(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Select your character's color",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          transform: Matrix4.translationValues(0, -50, 0),
                          height: 200,
                          width: 200,
                          child: PlayerSpriteSheet.talk(PlayerColor.green)
                              .asWidget(),
                        ),
                        GameButton(
                          expanded: true,
                          onPressed: _createMatchMaker,
                          text: 'Start',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createMatchMaker() {
    RoomMatchRoute.open(context);
  }
}
