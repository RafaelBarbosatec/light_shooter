// ignore: depend_on_referenced_packages
import 'package:bonfire/state_manager/bonfire_injector.dart';
import 'package:light_shooter/game/remote_player/remote_breaker_controlller.dart';
import 'package:light_shooter/server_conection/server_client.dart';
import 'package:light_shooter/server_conection/websocket_client.dart';

T inject<T extends Object>() => BonfireInjector().get<T>();

class Bootstrap {
  static run() {
    BonfireInjector().put((i) => ServerClient());
    BonfireInjector().put((i) => WebsocketClient());
    BonfireInjector().putFactory((i) => RemoteBreakerControlller(i.get()));
  }
}
