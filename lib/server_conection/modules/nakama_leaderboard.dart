// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:light_shooter/server_conection/modules/nakama_auth.dart';
import 'package:nakama/nakama.dart';

class NakamaLeaderboard {
  final NakamaBaseClient nakamaClient;
  final NakamaAuth auth;
  NakamaLeaderboard(this.nakamaClient, this.auth);

  Future<LeaderboardRecord> addLeaderboardScore(int score) async {
    return nakamaClient.writeLeaderboardRecord(
      session: auth.getSession(),
      leaderboardName: 'wins',
      score: score,
    );
  }
}
