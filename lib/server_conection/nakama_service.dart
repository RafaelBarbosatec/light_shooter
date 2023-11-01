// ignore: depend_on_referenced_packages
import 'package:light_shooter/server_conection/modules/nakama_auth.dart';
import 'package:light_shooter/server_conection/modules/nakama_leaderboard.dart';
import 'package:light_shooter/server_conection/modules/nakama_websocket.dart';
import 'package:nakama/nakama.dart';

class NakamaService {
  final String host;
  late final NakamaBaseClient _nakamaClient;
  NakamaAuth? _auth;
  NakamaWebsocket? _websocket;
  NakamaLeaderboard? _leaderboard;

  NakamaService({
    String? host,
    bool ssl = false,
  }) : host = host ?? '127.0.0.1' {
    _nakamaClient = getNakamaClient(
      host: host,
      ssl: ssl,
      serverKey: 'defaultkey',
    );
  }

  NakamaAuth auth() {
    _auth ??= NakamaAuth(_nakamaClient);
    return _auth!;
  }

  NakamaWebsocket websocket() {
    _websocket ??= NakamaWebsocket(host: host)..init(auth().getSession());
    return _websocket!;
  }

  NakamaLeaderboard leaderboard() {
    _leaderboard ??= NakamaLeaderboard(_nakamaClient, auth());
    return _leaderboard!;
  }
}
