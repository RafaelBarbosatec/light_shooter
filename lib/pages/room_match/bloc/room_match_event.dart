part of 'room_match_bloc.dart';

@immutable
abstract class RoomMatchEvent {}

class InitScreenEvent extends RoomMatchEvent {
  final PlayerCustomization custom;

  InitScreenEvent(this.custom);
}

class MatchedEvent extends RoomMatchEvent {
  final MatchmakerMatched matched;
  MatchedEvent(this.matched);
}

class CancelMatchMakerEvent extends RoomMatchEvent {
  final bool withPop;

  CancelMatchMakerEvent({this.withPop = true});
}

class DisposeEvent extends RoomMatchEvent {}
