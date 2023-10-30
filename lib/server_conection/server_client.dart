import 'dart:math';

// ignore: depend_on_referenced_packages
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

  Future<Session> signInDevice({String? nickName}) {
    if (_session == null) {
      String deviceId = Random().nextInt(9000).toString();
      return _nakamaClient
          .authenticateDevice(
        deviceId: 'fd6e533e-0cdd-408a-a8dc-4eeac103$deviceId',
        create: true,
        username: nickName,
      )
          .then((value) {
        return _session = value;
      });
    } else {
      return Future.value(_session);
    }
  }

  Future<Session> signInEmail({
    String? username,
    required String email,
    required String password,
    bool create = false,
  }) {
    if (_session == null) {
      return _nakamaClient
          .authenticateEmail(
        email: email,
        password: password,
        create: create,
        username: username,
      )
          .then((value) {
        return _session = value;
      });
    } else {
      return Future.value(_session);
    }
  }

  Future<Account?> getAccount() {
    if (_session != null) {
      return _nakamaClient.getAccount(_session!);
    } else {
      return Future.value(null);
    }
  }

  Future addLeaderboardScore(int score) async {
    if (_session != null) {
      return _nakamaClient.writeLeaderboardRecord(
        session: _session!,
        leaderboardName: 'PlayerRank',
        score: score,
      );
    }
  }

  Future logout() async {
    if (_session != null) {
      await _nakamaClient.sessionLogout(session: _session!);
      _session = null;
    } else {
      return Future.value();
    }
  }

  Session getSession() {
    if (_session == null) {
      throw Exception('You are not signed');
    }
    return _session!;
  }
}
