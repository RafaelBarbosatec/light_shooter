// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:light_shooter/game/util/player_spritesheet.dart';

class PlayerCustomization {
  final PlayerColor color;
  final String skin;

  const PlayerCustomization({this.color = PlayerColor.blue, this.skin = ''});

  factory PlayerCustomization.fromMap(Map<String, String?> map) {
    return PlayerCustomization(
      skin: map['skin'] ?? '',
      color: PlayerColor.fromName(map['color']),
    );
  }
  Map<String, String> toMap() {
    return {
      'color': color.name,
      'skin': skin,
    };
  }

  PlayerCustomization copyWith({
    PlayerColor? color,
    String? skin,
  }) {
    return PlayerCustomization(
      color: color ?? this.color,
      skin: skin ?? this.skin,
    );
  }
}
