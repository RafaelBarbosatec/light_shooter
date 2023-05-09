// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'room_match_bloc.dart';

@immutable
class RoomMatchState {
  final GameProperties? gameProperties;
  final String ticket;
  final bool goBack;

  const RoomMatchState({
    this.gameProperties,
    this.ticket = '',
    this.goBack = false,
  });

  RoomMatchState copyWith({
    GameProperties? gameProperties,
    String? ticket,
    bool? goBack,
  }) {
    return RoomMatchState(
      gameProperties: gameProperties,
      ticket: ticket ?? this.ticket,
      goBack: goBack ?? false,
    );
  }
}
