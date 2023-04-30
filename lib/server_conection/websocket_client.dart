import 'package:nakama/nakama.dart';
import 'package:nakama/rtapi.dart' as rt;

class WebsocketClient {
  final String host;
  NakamaWebsocketClient? _websocketClient;
  rt.MatchmakerTicket? matchmakerTicket;
  rt.Match? matched;

  WebsocketClient({this.host = '127.0.0.1'});

  void init(Session session) {
    _websocketClient = NakamaWebsocketClient.init(
      host: host,
      ssl: false,
      token: session.token,
    );
  }

  Future<rt.MatchmakerTicket> createMatchMaker({
    int minCount = 2,
    int maxCount = 4,
  }) {
    if (_websocketClient == null) {
      throw Exception('WebsocketClient not initializaed');
    }

    if (matchmakerTicket != null) {
      throw Exception('Already in a match');
    }
    return _websocketClient!
        .addMatchmaker(
      minCount: 2,
      maxCount: 4,
      query: '*',
    )
        .then(
      (value) {
        return matchmakerTicket = value;
      },
    );
  }

  bool get inMatch => matchmakerTicket != null;

  Future exitMatchmaker() async {
    if (_websocketClient == null) {
      throw Exception('WebsocketClient not initializaed');
    }
    if (matchmakerTicket != null) {
      await _websocketClient!.removeMatchmaker(matchmakerTicket!.ticket);
      matchmakerTicket = null;
    }
  }

  Stream<rt.MatchmakerMatched> listenMatchmaker() {
    if (_websocketClient == null) {
      throw Exception('WebsocketClient not initializaed');
    }
    return _websocketClient!.onMatchmakerMatched;
  }

  Future<rt.Match> joinMatch(rt.MatchmakerMatched matched) {
    if (_websocketClient == null) {
      throw Exception('WebsocketClient not initializaed');
    }
    return _websocketClient!
        .joinMatch(matched.matchId, token: matched.token)
        .then((value) {
      return this.matched = value;
    });
  }

  Future<List> sendMatchData(int code, String data) {
    if (_websocketClient == null) {
      throw Exception('WebsocketClient not initializaed');
    }
    if (matched?.matchId == null) {
      throw Exception('There is not matched');
    }
    return _websocketClient!.sendMatchData(
      matchId: matched!.matchId,
      opCode: Int64(code),
      data: data.codeUnits,
    );
  }
}
