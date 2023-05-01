// ignore: depend_on_referenced_packages
import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:nakama/nakama.dart';

class WebsocketClient {
  final String host;
  NakamaWebsocketClient? _websocketClient;
  MatchmakerTicket? matchmakerTicket;
  Match? matched;
  final List<Function(MatchData data)> _onMatchDataObservers = [];
  final List<Function(MatchPresenceEvent data)> _onMatchPresenceObservers = [];

  StreamSubscription? onMatchDataSubscription;
  StreamSubscription? onMatchPresenceSubscription;

  WebsocketClient({this.host = '127.0.0.1'});

  void init(Session session) {
    _websocketClient = NakamaWebsocketClient.init(
      host: host,
      ssl: false,
      token: session.token,
    );
  }

  Future<MatchmakerTicket> createMatchMaker({
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

  Stream<MatchmakerMatched> listenMatchmaker() {
    if (_websocketClient == null) {
      throw Exception('WebsocketClient not initializaed');
    }
    return _websocketClient!.onMatchmakerMatched;
  }

  Future<Match> joinMatch(MatchmakerMatched matched) {
    if (_websocketClient == null) {
      throw Exception('WebsocketClient not initializaed');
    }
    return _websocketClient!
        .joinMatch(matched.matchId ?? '', token: matched.token)
        .then((value) {
      _startListens();
      return this.matched = value;
    });
  }

  Future leaveMatch() async {
    if (_websocketClient == null) {
      throw Exception('WebsocketClient not initializaed');
    }
    if (matched?.matchId == null) {
      throw Exception('There is not matched');
    }
    await _websocketClient!.leaveMatch(matched?.matchId ?? '');
    _stopListens();
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

  void _startListens() {
    onMatchDataSubscription =
        _websocketClient!.onMatchData.listen(_onMatchObserver);
    onMatchPresenceSubscription =
        _websocketClient!.onMatchPresence.listen(_onMatchPresence);
  }

  void _stopListens() {
    onMatchDataSubscription?.cancel();
    onMatchPresenceSubscription?.cancel();
    _onMatchDataObservers.clear();
    _onMatchPresenceObservers.clear();
  }

  void _onMatchObserver(MatchData event) {
    for (var observer in _onMatchDataObservers) {
      observer(event);
    }
  }

  void _onMatchPresence(MatchPresenceEvent event) {
    for (var observer in _onMatchPresenceObservers) {
      observer(event);
    }
  }

  void addOnMatchDataObserser(Function(MatchData data) observer) {
    _onMatchDataObservers.add(observer);
  }

  void removeOnMatchDataObserser(Function(MatchData data) observer) {
    _onMatchDataObservers.remove(observer);
  }

  void addOnMatchPresenceObserser(Function(MatchPresenceEvent data) observer) {
    _onMatchPresenceObservers.add(observer);
  }

  void removeOnMatchPresenceObserser(
      Function(MatchPresenceEvent data) observer) {
    _onMatchPresenceObservers.remove(observer);
  }

  Match getMatch() {
    if (matched?.matchId == null) {
      throw Exception('There is not matched');
    }
    return matched!;
  }
}
