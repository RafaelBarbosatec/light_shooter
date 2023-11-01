import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:light_shooter/game/util/player_customization.dart';
import 'package:light_shooter/game/util/player_spritesheet.dart';
import 'package:light_shooter/pages/login/login_route.dart';
import 'package:light_shooter/pages/room_match/room_match_route.dart';
import 'package:light_shooter/server_conection/nakama_service.dart';
import 'package:light_shooter/shared/bootstrap.dart';
import 'package:light_shooter/shared/theme/game_colors.dart';
import 'package:light_shooter/shared/widgets/game_button.dart';
import 'package:light_shooter/shared/widgets/game_color_selector.dart';
import 'package:light_shooter/shared/widgets/game_container.dart';
// ignore: depend_on_referenced_packages
import 'package:nakama/nakama.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late NakamaService _serverClient;

  PlayerCustomization customization = const PlayerCustomization();

  @override
  void initState() {
    _serverClient = inject();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: Stack(
        children: [
          Center(
            child: ListView(
              shrinkWrap: true,
              children: [
                Center(
                  child: FutureBuilder<Account?>(
                    future: _serverClient.auth().getAccount(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          'Hello ${snapshot.data?.user.username}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 4,
                    ),
                    child: GameContainer(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Select your character's color",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Transform.scale(
                                scale: 2,
                                child: Container(
                                  transform:
                                      Matrix4.translationValues(0, -25, 0),
                                  height: 100,
                                  width: 100,
                                  child: PlayerSpriteSheet.talk(
                                          customization.color)
                                      .asWidget(),
                                ),
                              ),
                            ),
                            GameColorSelector(
                              colorSelected: customization.color,
                              onChanged: (color) {
                                setState(() {
                                  customization = customization.copyWith(
                                    color: color,
                                  );
                                });
                              },
                            ),
                            const SizedBox(height: 32),
                            GameButton(
                              expanded: true,
                              onPressed: _createMatchMaker,
                              text: 'Play',
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
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                onPressed: _logout,
                icon: const Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _createMatchMaker() {
    RoomMatchRoute.open(context, customization);
  }

  void _logout() async {
    await _serverClient.auth().logout().catchError((e) {});
    if (mounted) {
      LoginRoute.open(context);
    }
  }
}
