import 'dart:math';

import 'package:nakama/api.dart' as api;
import 'package:nakama/nakama.dart';

class ServerClient {
  late final NakamaBaseClient _nakamaClient;

  Session? _session;

  ServerClient({String? host, bool ssl = false}) {
    _nakamaClient = getNakamaClient(
      host: host ?? '127.0.0.1',
      ssl: ssl,
      serverKey: 'defaultkey',
    );
  }

  Future<Session> signIn() {
    if (_session == null) {
      String deviceId = Random().nextInt(1000000).toString();
      return _nakamaClient
          .authenticateEmail(email: '$deviceId@email.com', password: 'password')
          .then((value) {
        return _session = value;
      });
    } else {
      return Future.value(_session);
    }
  }

  Future<api.Account?> getAccount() {
    if (_session != null) {
      return _nakamaClient.getAccount(_session!);
    } else {
      return Future.value(null);
    }
  }

  // Future loggot() async {
  //   if (_session != null) {
  //     await _nakamaClient.a(session: _session!);
  //     _session = null;
  //   } else {
  //     return Future.value();
  //   }
  // }
}
