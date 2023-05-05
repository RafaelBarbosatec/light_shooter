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
}
