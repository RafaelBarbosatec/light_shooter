import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:light_shooter/game/player/weapons/bullet_capsule.dart';
import 'package:light_shooter/game/util/player_spritesheet.dart';

class BreakerCannon extends GameComponent with Follower, UseSpriteAnimation {
  double dt = 0;
  final Color flash = const Color(0xFF73eff7).withOpacity(0.5);
  BreakerCannon(GameComponent target) {
    size = Vector2.all(64);
    setupFollower(offset: Vector2(0, 16), target: target);
  }

  @override
  void update(double dt) {
    this.dt = dt;
    isFlipHorizontally =
        (followerTarget as Movement).lastDirectionHorizontal != Direction.right;

    super.update(dt);
  }

  @override
  Future<void>? onLoad() async {
    animation = await PlayerSpriteSheet.gun;
    return super.onLoad();
  }

  void execShootAndChangeAngle(double radAngle) {
    changeAngle(radAngle);
    if (checkInterval('SHOOT_INTERVAL', 500, dt)) {
      execShoot(radAngle);
    }
  }

  void execShoot(double radAngle) {
    playSpriteAnimationOnce(
      PlayerSpriteSheet.gunShot,
    );
    simpleAttackRangeByAngle(
      animation: PlayerSpriteSheet.bullet,
      size: Vector2.all(32),
      angle: radAngle,
      damage: 100,
      speed: 250,
      collision: CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Vector2.all(16),
            align: Vector2.all(16) / 2,
          )
        ],
      ),
      marginFromOrigin: -3,
      attackFrom: AttackFromEnum.PLAYER_OR_ALLY,
    );
    gameRef.camera.shake(intensity: 1);
    gameRef.colorFilter?.config.color = flash;
    gameRef.colorFilter?.animateTo(Colors.transparent);
    gameRef.add(BulletCapsule(center, _getAnglecapsule(radAngle)));
  }

  void changeAngle(double radAngle) {
    angle = radAngle + ((isFlipHorizontally && radAngle != 0) ? pi : 0);
  }

  double _getAnglecapsule(double radAngle) {
    double angle = radAngle + pi / 2;
    Direction angleDirection = BonfireUtil.getDirectionFromAngle(angle);
    if (angleDirection == Direction.down ||
        angleDirection == Direction.downLeft ||
        angleDirection == Direction.downRight) {
      angle += pi;
    }
    return angle;
  }

  void reload() {
    playSpriteAnimationOnce(
      PlayerSpriteSheet.gunReload,
    );
  }
}
