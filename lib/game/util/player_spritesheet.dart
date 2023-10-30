import 'package:bonfire/bonfire.dart';

enum PlayerColor {
  blue,
  green,
  red;

  factory PlayerColor.fromName(String? name) {
    if (name == null) {
      return PlayerColor.blue;
    }
    return PlayerColor.values.firstWhere((element) => element.name == name);
  }

  Color getColor() {
    switch (this) {
      case PlayerColor.blue:
        return const Color(0xFF3b5dc9);
      case PlayerColor.green:
        return const Color(0xFF257179);
      case PlayerColor.red:
        return const Color(0xFFb13e53);
    }
  }
}

class PlayerSpriteSheet {
  static Future<SpriteAnimation> idle(PlayerColor color) =>
      SpriteAnimation.load(
        'player_${color.name}.png',
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: 0.1,
          textureSize: Vector2.all(32),
        ),
      );

  static Future<SpriteAnimation> run(PlayerColor color) => SpriteAnimation.load(
        'player_${color.name}.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.2,
          textureSize: Vector2.all(32),
          texturePosition: Vector2(0, 64),
        ),
      );

  static Future<SpriteAnimation> die(PlayerColor color) => SpriteAnimation.load(
        'player_${color.name}.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2.all(32),
          texturePosition: Vector2(0, 96),
        ),
      );

  static Future<SpriteAnimation> talk(PlayerColor color) =>
      SpriteAnimation.load(
        'player_${color.name}.png',
        SpriteAnimationData.sequenced(
          amount: 2,
          stepTime: 0.1,
          textureSize: Vector2.all(32),
          texturePosition: Vector2(0, 32),
        ),
      );

  static Future<SpriteAnimation> gun(PlayerColor color) => SpriteAnimation.load(
        'gun_${color.name}.png',
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: 0.1,
          textureSize: Vector2.all(32),
        ),
      );

  static Future<SpriteAnimation> gunShot(PlayerColor color) =>
      SpriteAnimation.load(
        'gun_${color.name}.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.1,
          textureSize: Vector2.all(32),
          texturePosition: Vector2(0, 64),
        ),
      );

  static Future<SpriteAnimation> gunReload(PlayerColor color) =>
      SpriteAnimation.load(
        'gun_${color.name}.png',
        SpriteAnimationData.sequenced(
          amount: 5,
          stepTime: 0.1,
          textureSize: Vector2.all(32),
          texturePosition: Vector2(0, 32),
        ),
      );

  static Future<SpriteAnimation> get bullet => SpriteAnimation.load(
        'bullet_blue.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.1,
          textureSize: Vector2.all(16),
        ),
      );

  static Future<SpriteAnimation> get bulletCapsule => SpriteAnimation.load(
        'bullet_blue.png',
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: 0.1,
          textureSize: Vector2.all(16),
          texturePosition: Vector2(0, 16),
        ),
      );

  static SimpleDirectionAnimation animation(PlayerColor color) =>
      SimpleDirectionAnimation(
        idleRight: idle(color),
        runRight: run(color),
        others: {
          'talk': talk(color),
        },
      );
}
