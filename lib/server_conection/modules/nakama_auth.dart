import 'package:nakama/nakama.dart';

class NakamaAuth {
  final NakamaBaseClient _nakamaClient;
  Session? _session;

  NakamaAuth(this._nakamaClient);

  Future<Session> authenticateEmail({
    String? username,
    required String email,
    required String password,
    bool create = false,
  }) {
    return _nakamaClient
        .authenticateEmail(
      email: email,
      password: password,
      create: create,
      username: username,
    )
        .then((value) {
      _session = value;
      return value;
    });
  }

  Future<Account> getAccount() {
    return _nakamaClient.getAccount(getSession());
  }

  Session getSession() {
    if (_session == null) {
      throw Exception('Session not found. Please authenticate!');
    }
    return _session!;
  }

  Future<void> logout() {
    return _nakamaClient.sessionLogout(session: getSession()).then((value) {
      _session = null;
    });
  }
}
