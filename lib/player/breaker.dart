import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:light_shooter/player/weapons/breaker_cannon.dart';
import 'package:light_shooter/util/player_spritesheet.dart';

class Breaker extends SimplePlayer with ObjectCollision {
  BreakerCannon? gun;
  final Color flashDamage = Colors.red;
  Breaker({
    required super.position,
  }) : super(
          size: Vector2.all(64),
          animation: PlayerSpriteSheet.animation,
          speed: 100,
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
  void joystickAction(JoystickActionEvent event) {
    if (event.id == 1) {
      if (event.event == ActionEvent.MOVE) {
        gun?.execShootAndChangeAngle(event.radAngle);
      }
      if (event.event == ActionEvent.UP) {
        gun?.changeAngle(0);
      }
    }
    if (event.id == 2 && event.event == ActionEvent.DOWN) {
      gun?.reload();
    }
    super.joystickAction(event);
  }

  @override
  void onMount() {
    add(gun = BreakerCannon());
    super.onMount();
  }

  @override
  void receiveDamage(AttackFromEnum attacker, double damage, identify) {
    gameRef.colorFilter?.config.color = flashDamage;
    gameRef.colorFilter?.animateTo(Colors.transparent);
    super.receiveDamage(attacker, damage, identify);
  }
}
