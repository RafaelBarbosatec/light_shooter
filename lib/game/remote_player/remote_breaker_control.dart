import 'package:bonfire/npc/enemy/simple_enemy.dart';
import 'package:light_shooter/game/remote_player/remote_breaker.dart';
// ignore: depend_on_referenced_packages
import 'package:nakama/nakama.dart';

mixin RemoteBreakerControl on SimpleEnemy {
  RemoteBreaker get breaker => this as RemoteBreaker;
  @override
  void onMount() {
    breaker.websocketClient.addOnMatchDataObserser(_onDataObserver);
    super.onMount();
  }

  _onDataObserver(MatchData data) {
    print(data);
    if (data.presence.userId == breaker.id) {
      if (data.opCode == 0) {
        String event = String.fromCharCodes(data.data);
        print(event);
      }
    }
  }
}
