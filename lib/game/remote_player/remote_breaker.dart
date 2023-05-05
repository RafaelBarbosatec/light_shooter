import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:light_shooter/game/player/weapons/breaker_cannon.dart';
import 'package:light_shooter/game/remote_player/remote_breaker_control.dart';
import 'package:light_shooter/game/util/player_spritesheet.dart';
import 'package:light_shooter/server_conection/websocket_client.dart';

class RemoteBreaker extends SimpleEnemy
    with ObjectCollision, RemoteBreakerControl, UseBarLife {
  BreakerCannon? gun;
  final Color flashDamage = Colors.red;
  final bool enabledMouse;
  final String id;
  final WebsocketClient websocketClient;
  final PlayerColor color;
  RemoteBreaker({
    required this.id,
    required super.position,
    required this.websocketClient,
    required this.color,
    this.enabledMouse = false,
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
