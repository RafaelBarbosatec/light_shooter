// ignore: depend_on_referenced_packages

import 'package:get_it/get_it.dart';
import 'package:light_shooter/pages/login/bloc/login_bloc.dart';
import 'package:light_shooter/pages/room_match/bloc/room_match_bloc.dart';
import 'package:light_shooter/server_conection/nakama_service.dart';

final getIt = GetIt.instance;
T inject<T extends Object>() => getIt.get<T>();

class Bootstrap {
  static run() {
    getIt.registerLazySingleton(() => NakamaService(host: '192.168.0.11'));
    getIt.registerFactory(() => LoginBloc(getIt.get()));
    getIt.registerFactory(() => RoomMatchBloc(getIt.get()));
  }
}
