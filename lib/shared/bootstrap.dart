// ignore: depend_on_referenced_packages
import 'package:get_it/get_it.dart';
import 'package:light_shooter/server_conection/server_client.dart';
import 'package:light_shooter/server_conection/websocket_client.dart';

final _getIt = GetIt.instance;

T inject<T extends Object>() => _getIt.get<T>();

class Bootstrap {
  static run() {
    _getIt.registerLazySingleton(() => ServerClient());
    _getIt.registerLazySingleton(() => WebsocketClient());
  }
}
