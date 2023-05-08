import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:light_shooter/game/player/weapons/breaker_cannon.dart';
import 'package:light_shooter/game/remote_player/remote_breaker_controlller.dart';
import 'package:light_shooter/game/util/player_spritesheet.dart';

class RemoteBreaker extends SimpleEnemy
    with
        ObjectCollision,
        UseBarLife,
        UseStateController<RemoteBreakerControlller> {
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
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: size / 4,
            align: Vector2(size.y * 0.35, size.x * 0.70),
          ),
        ],
      ),
    );

    setupBarLife(
      size: Vector2(width / 2, 6),
      borderRadius: BorderRadius.circular(10),
      barLifePosition: BarLifePorition.bottom,
    );
  }

  @override
  void onMount() {
    add(
      gun = BreakerCannon(
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
