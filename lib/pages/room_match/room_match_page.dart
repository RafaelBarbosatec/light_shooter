import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:light_shooter/game/game_route.dart';
import 'package:light_shooter/game/util/player_customization.dart';
import 'package:light_shooter/pages/room_match/bloc/room_match_bloc.dart';
import 'package:light_shooter/shared/bootstrap.dart';
import 'package:light_shooter/shared/theme/game_colors.dart';
import 'package:light_shooter/shared/widgets/game_button.dart';
import 'package:light_shooter/shared/widgets/game_container.dart';
// ignore: depend_on_referenced_packages

class RoomMatchPage extends StatefulWidget {
  final PlayerCustomization custom;
  const RoomMatchPage({super.key, required this.custom});

  @override
  State<RoomMatchPage> createState() => _RoomMatchPageState();
}

class _RoomMatchPageState extends State<RoomMatchPage> {
  late RoomMatchBloc _bloc;

  @override
  void initState() {
    _bloc = inject();
    _bloc.add(InitScreenEvent(widget.custom));
    super.initState();
  }

  @override
  void dispose() {
    _bloc.add(DisposeEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        backgroundColor: GameColors.background,
        body: BlocConsumer<RoomMatchBloc, RoomMatchState>(
          bloc: _bloc,
          listener: (context, state) {
            if (state.goBack) {
              Navigator.pop(context);
            }
            if (state.gameProperties != null) {
              GameRoute.open(context, state.gameProperties!);
            }
          },
          builder: (context, state) {
            return Center(
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Center(
                    child: Text(
                      'Looking for player',
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
                          if (state.ticket.isNotEmpty) ...[
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
                              state.ticket,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 32),
                            GameButton(
                              expanded: true,
                              onPressed: () =>
                                  _bloc.add(CancelMatchMakerEvent()),
                              text: 'Cancel',
                            )
                          ]
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
