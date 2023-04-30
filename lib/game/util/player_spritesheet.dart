import 'package:bonfire/bonfire.dart';

class PlayerSpriteSheet {
  static Future<SpriteAnimation> get idle => SpriteAnimation.load(
        'player_blue.png',
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: 0.1,
          textureSize: Vector2.all(32),
        ),
      );

  static Future<SpriteAnimation> get run => SpriteAnimation.load(
        'player_blue.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.2,
          textureSize: Vector2.all(32),
          texturePosition: Vector2(0, 64),
        ),
      );

  static Future<SpriteAnimation> get talk => SpriteAnimation.load(
        'player_blue.png',
        SpriteAnimationData.sequenced(
          amount: 2,
          stepTime: 0.1,
          textureSize: Vector2.all(32),
          texturePosition: Vector2(0, 32),
        ),
      );

  static Future<SpriteAnimation> get gun => SpriteAnimation.load(
        'gun_blue.png',
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: 0.1,
          textureSize: Vector2.all(32),
        ),
      );

  static Future<SpriteAnimation> get gunShot => SpriteAnimation.load(
        'gun_blue.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.1,
          textureSize: Vector2.all(32),
          texturePosition: Vector2(0, 64),
        ),
      );

  static Future<SpriteAnimation> get gunReload => SpriteAnimation.load(
        'gun_blue.png',
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

  static SimpleDirectionAnimation get animation => SimpleDirectionAnimation(
        idleRight: idle,
        runRight: run,
        others: {
          'talk': talk,
        },
      );
}
