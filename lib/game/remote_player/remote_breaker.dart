import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:light_shooter/game/player/weapons/breaker_cannon.dart';
import 'package:light_shooter/game/remote_player/remote_breaker_control.dart';
import 'package:light_shooter/game/util/player_spritesheet.dart';
import 'package:light_shooter/server_conection/websocket_client.dart';

class RemoteBreaker extends SimpleEnemy
    with ObjectCollision, RemoteBreakerControl {
  BreakerCannon? gun;
  final Color flashDamage = Colors.red;
  final bool enabledMouse;
  final String id;
  WebsocketClient websocketClient;
  RemoteBreaker({
    required this.id,
    required super.position,
    required this.websocketClient,
    this.enabledMouse = false,
  }) : super(
          size: Vector2.all(64),
          animation: PlayerSpriteSheet.animation,
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
  }

  @override
  void onMount() {
    gameRef.add(
      gun = BreakerCannon(
        this,
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
    gun?.removeFromParent();
    animation?.playOnce(
      PlayerSpriteSheet.die,
      onFinish: removeFromParent,
    );
    super.die();
  }
}
