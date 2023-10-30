import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:light_shooter/game/player/weapons/breaker_cannon.dart';
import 'package:light_shooter/game/remote_player/remote_breaker_controlller.dart';
import 'package:light_shooter/game/util/player_spritesheet.dart';

class RemoteBreaker extends SimpleEnemy
    with BlockMovementCollision, UseLifeBar, RemoteBreakerControlller {
  BreakerCannon? gun;
  final String id;
  final PlayerColor color;
  final String name;

  RemoteBreaker({
    required this.id,
    required super.position,
    required this.color,
    this.name = '',
  }) : super(
          size: Vector2.all(64),
          animation: PlayerSpriteSheet.animation(color),
          speed: 60,
        ) {
    setupLifeBar(
      size: Vector2(width / 2, 6),
      borderRadius: BorderRadius.circular(10),
      barLifeDrawPosition: BarLifeDrawPorition.bottom,
    );
  }

  @override
  Future<void> onLoad() async {
    await add(
      RectangleHitbox(
        size: size / 4,
        position: Vector2(size.y * 0.35, size.x * 0.70),
      ),
    );
    return super.onLoad();
  }

  @override
  void onMount() {
    add(
      gun = BreakerCannon(
        Vector2(32, 44),
        color,
        withScreenEffect: false,
        blockShootWithoutBullet: false,
        attackFrom: AttackFromEnum.ENEMY,
      ),
    );
    super.onMount();
  }

  @override
  void receiveDamage(AttackFromEnum attacker, double damage, identify) {}

  @override
  void die() {
    animation?.playOnce(
      PlayerSpriteSheet.die(color),
      onFinish: removeFromParent,
    );
    super.die();
  }
}
