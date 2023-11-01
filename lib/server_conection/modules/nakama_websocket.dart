// ignore: depend_on_referenced_packages
// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:math';

// ignore: depend_on_referenced_packages
import 'package:nakama/nakama.dart';

class NakamaWebsocket {
  static const PARAM_NUMBER_POSITION = 'numberPosition';
  final String host;
  NakamaWebsocketClient? _websocketClient;
  MatchmakerTicket? matchmakerTicket;
  Match? match;
  MatchmakerMatched? matched;
  final List<Function(MatchData data)> _onMatchDataObservers = [];
  final List<Function(MatchPresenceEvent data)> _onMatchPresenceObservers = [];

  StreamSubscription? onMatchDataSubscription;
  StreamSubscription? onMatchPresenceSubscription;

  NakamaWebsocket({this.host = '127.0.0.1'});

  void init(Session session) {
    _websocketClient = NakamaWebsocketClient.init(
      host: host,
      ssl: false,
      token: session.token,
    );
  }

  Future<MatchmakerTicket> createMatchMaker({
    int minCount = 2,
    int maxCount = 2,
    Map<String, String>? propertiers,
  }) {
    if (_websocketClient == null) {
      throw Exception('WebsocketClient not initializaed');
    }

    if (matchmakerTicket != null) {
      throw Exception('Already in a match');
    }
    return _websocketClient!
        .addMatchmaker(
      minCount: minCount,
      maxCount: maxCount,
      query: '*',
      numericProperties: {
        PARAM_NUMBER_POSITION: Random().nextInt(90000).toDouble(),
      },
      stringProperties: propertiers,
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
    this.matched = matched;
    return _websocketClient!
        .joinMatch(matched.matchId ?? '', token: matched.token)
        .then(
      (value) {
        _startListens();
        return match = value;
      },
    );
  }

  Future leaveMatch() async {
    if (_websocketClient == null) {
      throw Exception('WebsocketClient not initializaed');
    }
    if (match?.matchId == null) {
      throw Exception('There is not matched');
    }
    await _websocketClient!.leaveMatch(match?.matchId ?? '');
    _stopListens();
  }

  Future<List> sendMatchData(int code, String data) {
    if (_websocketClient == null) {
      throw Exception('WebsocketClient not initializaed');
    }
    if (match?.matchId == null) {
      throw Exception('There is not matched');
    }

    return _websocketClient!.sendMatchData(
      matchId: match!.matchId,
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
    if (!_onMatchDataObservers.any((element) => element == observer)) {
      _onMatchDataObservers.add(observer);
    }
  }

  void removeOnMatchDataObserser(Function(MatchData data) observer) {
    _onMatchDataObservers.remove(observer);
  }

  void addOnMatchPresenceObserser(Function(MatchPresenceEvent data) observer) {
    if (!_onMatchPresenceObservers.any((element) => element == observer)) {
      _onMatchPresenceObservers.add(observer);
    }
  }

  void removeOnMatchPresenceObserser(
      Function(MatchPresenceEvent data) observer) {
    _onMatchPresenceObservers.remove(observer);
  }

  Match getMatch() {
    if (match?.matchId == null) {
      throw Exception('There is not matched');
    }
    return match!;
  }

  MatchmakerMatched getMatched() {
    if (matched?.matchId == null) {
      throw Exception('There is not matched');
    }
    return matched!;
  }
}
