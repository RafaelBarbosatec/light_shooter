import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:light_shooter/game/player/weapons/bullet_capsule.dart';
import 'package:light_shooter/game/util/player_spritesheet.dart';

class BreakerCannon extends GameDecoration with ChangeNotifier {
  double dt = 0;
  final double timeToReload = 5;
  final Color flash = const Color(0xFF73eff7).withOpacity(0.5);
  final bool withScreenEffect;
  final AttackFromEnum attackFrom;
  final PlayerColor color;
  final bool blockShootWithoutBullet;
  SpriteAnimation? _normalAnimation;
  SpriteAnimation? _reloadAnimation;
  int _countBullet = 5;
  bool reloading = false;
  double currentTimeReload = 0;
  BreakerCannon(
    Vector2 position,
    this.color, {
    this.withScreenEffect = true,
    this.blockShootWithoutBullet = true,
    this.attackFrom = AttackFromEnum.PLAYER_OR_ALLY,
  }) : super.withAnimation(
          animation: PlayerSpriteSheet.gun(color),
          position: position,
          size: Vector2.all(64),
        );

  @override
  void update(double dt) {
    this.dt = dt;

    if ((parent as Movement).lastDirectionHorizontal != Direction.right) {
      if (!isFlippedHorizontally) {
        flipHorizontally();
      }
    } else {
      if (isFlippedHorizontally) {
        flipHorizontally();
      }
    }

    if (reloading) {
      currentTimeReload += dt;
      if (currentTimeReload >= timeToReload) {
        reloading = false;
        _countBullet = 5;
        setAnimation(_normalAnimation);
      }
      notifyListeners();
    }
    super.update(dt);
  }

  @override
  Future<void> onLoad() async {
    _reloadAnimation = await PlayerSpriteSheet.gunReload(color);
    _normalAnimation = await PlayerSpriteSheet.gun(color);
    anchor = Anchor.center;
    return super.onLoad();
  }

  void execShoot(double damage) {
    if (_countBullet <= 0 && blockShootWithoutBullet) {
      return;
    }
    playSpriteAnimationOnce(
      PlayerSpriteSheet.gunShot(color),
    );
    simpleAttackRangeByAngle(
      animation: PlayerSpriteSheet.bullet,
      size: Vector2.all(32),
      angle: radAngle,
      damage: damage,
      speed: 300,
      collision: RectangleHitbox(
        size: Vector2.all(16),
        position: Vector2.all(16) / 2,
      ),
      marginFromOrigin: -3,
      attackFrom: attackFrom,
    );
    if (withScreenEffect) {
      gameRef.camera.shake(
        intensity: 1,
        duration: const Duration(milliseconds: 200),
      );
      gameRef.colorFilter?.config.color = flash;
      gameRef.colorFilter?.animateTo(Colors.transparent);
    }

    gameRef.add(
      BulletCapsule(
        absoluteCenter,
        _getAnglecapsule(radAngle),
      ),
    );
    _countBullet--;
    if (_countBullet == 0) {
      currentTimeReload = 0;
      reloading = true;
      setAnimation(_reloadAnimation);
    }
    notifyListeners();
  }

  double radAngle = 0;

  void changeAngle(double radAngle) {
    this.radAngle = radAngle;
    angle = calculeNewAngle(radAngle);
  }

  double calculeNewAngle(double radAngle) {
    return radAngle + ((isFlippedHorizontally && radAngle != 0) ? pi : 0);
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
      PlayerSpriteSheet.gunReload(color),
    );
  }

  void addBullet(int count) {
    _countBullet = count;
  }

  int get countBullet => _countBullet;
}
