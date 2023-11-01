import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:light_shooter/game/game.dart';
import 'package:light_shooter/game/util/player_customization.dart';
import 'package:light_shooter/server_conection/modules/nakama_websocket.dart';
import 'package:light_shooter/server_conection/nakama_service.dart';
// ignore: implementation_imports
import 'package:nakama/src/models/matchmaker.dart';

part 'room_match_event.dart';
part 'room_match_state.dart';

class RoomMatchBloc extends Bloc<RoomMatchEvent, RoomMatchState> {
  final NakamaService _serverClient;

  List<Vector2> positionsToBorn = [
    Vector2(3, 3),
    Vector2(15, 15),
  ];

  StreamSubscription? subscription;
  RoomMatchBloc(this._serverClient) : super(const RoomMatchState()) {
    on<InitScreenEvent>(_onInitScreenEvent);
    on<MatchedEvent>(_onMatchedEvent);
    on<CancelMatchMakerEvent>(_onCancelMatchMaker);
    on<DisposeEvent>(_onDisposeEvent);
  }

  FutureOr<void> _onInitScreenEvent(
    InitScreenEvent event,
    Emitter<RoomMatchState> emit,
  ) async {
    subscription =
        _serverClient.websocket().listenMatchmaker().listen((matched) {
      add(MatchedEvent(matched));
    });
    await _serverClient
        .websocket()
        .createMatchMaker(propertiers: event.custom.toMap())
        .then((value) {
      emit(state.copyWith(ticket: value.ticket));
    });
  }

  FutureOr<void> _onMatchedEvent(
    MatchedEvent event,
    Emitter<RoomMatchState> emit,
  ) async {
    GameProperties properties = _getGameProperties(event.matched);
    await _serverClient.websocket().joinMatch(event.matched).then((value) {
      add(CancelMatchMakerEvent(withPop: false));
      emit(state.copyWith(gameProperties: properties));
    });
  }

  FutureOr<void> _onCancelMatchMaker(
    CancelMatchMakerEvent event,
    Emitter<RoomMatchState> emit,
  ) async {
    await _serverClient.websocket().exitMatchmaker().catchError((e) {});
    emit(state.copyWith(goBack: event.withPop));
  }

  FutureOr<void> _onDisposeEvent(
    DisposeEvent event,
    Emitter<RoomMatchState> emit,
  ) {
    subscription?.cancel();
  }

  GameProperties _getGameProperties(MatchmakerMatched event) {
    String userId = _serverClient.auth().getSession().userId;
    List<MatchmakerUser> users = event.users.toList();
    PlayerPropertie myProperties = PlayerPropertie(
      position: Vector2.zero(),
      userId: '',
    );
    List<PlayerPropertie> opponentPositions = [];

    users.sort(
      (a, b) {
        double firstNumber =
            a.numericProperties[NakamaWebsocket.PARAM_NUMBER_POSITION] ?? 0.0;
        double secondNumber =
            b.numericProperties[NakamaWebsocket.PARAM_NUMBER_POSITION] ?? 0.0;
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
