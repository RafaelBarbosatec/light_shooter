import 'dart:convert';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:light_shooter/game/player/weapons/breaker_cannon.dart';
import 'package:light_shooter/game/remote_player/remote_breaker.dart';
import 'package:light_shooter/game/util/player_spritesheet.dart';
import 'package:light_shooter/server_conection/messages/attack_message.dart';
import 'package:light_shooter/server_conection/websocket_client.dart';
import 'package:light_shooter/shared/enum/operation_code.dart';

class Breaker extends SimplePlayer with ObjectCollision, MouseGesture {
  BreakerCannon? gun;
  final Color flashDamage = Colors.red;
  final bool enabledMouse;
  final String id;
  WebsocketClient websocketClient;
  Breaker({
    required this.id,
    required super.position,
    required this.websocketClient,
    this.enabledMouse = false,
  }) : super(
          size: Vector2.all(64),
          animation: PlayerSpriteSheet.animation,
          speed: 60,
        ) {
    enabledDiagonalMovements = false;
    enableMouseGesture = enabledMouse;
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
        bool shoot = gun?.execShootAndChangeAngle(event.radAngle, 100) ?? false;
        if (shoot) {
          _sendShoot(event.radAngle, 100);
        }
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
    gameRef.add(gun = BreakerCannon(this));
    super.onMount();
  }

  @override
  void receiveDamage(AttackFromEnum attacker, double damage, identify) {
    gameRef.colorFilter?.config.color = flashDamage;
    gameRef.colorFilter?.animateTo(Colors.transparent);
    super.receiveDamage(attacker, damage, identify);
  }

  @override
  void onMouseCancel() {}

  @override
  void onMouseTap(MouseButton button) {}

  @override
  void onMouseScreenTapDown(int pointer, Vector2 position, MouseButton button) {
    var angle = BonfireUtil.angleBetweenPoints(
      center,
      gameRef.screenToWorld(position),
    );
    gun?.execShoot(angle, 100);
    _sendShoot(angle, 100);
    super.onMouseScreenTapDown(pointer, position, button);
  }

  @override
  void onMouseHoverScreen(int pointer, Vector2 position) {
    double angle = BonfireUtil.angleBetweenPoints(
      center,
      gameRef.screenToWorld(position),
    );
    gun?.changeAngle(angle);
    super.onMouseHoverScreen(pointer, position);
  }

  Direction? lastSOcketDirection;
  @override
  void onMove(double speed, Direction direction, double angle) {
    if (direction != lastSOcketDirection) {
      lastSOcketDirection = direction;
      websocketClient.sendMatchData(
        OperationCodeEnum.movement.index,
        direction.name,
      );
    }
    super.onMove(speed, direction, angle);
  }

  @override
  void idle() {
    websocketClient.sendMatchData(
      OperationCodeEnum.movement.index,
      'idle',
    );
    super.idle();
  }

  @override
  bool onCollision(GameComponent component, bool active) {
    if (component is RemoteBreaker) {
      return false;
    }
    return super.onCollision(component, active);
  }

  void _sendShoot(double angle, damage) {
    final attack = AttackMessage(damage, '', angle);
    websocketClient.sendMatchData(
      OperationCodeEnum.attack.index,
      jsonEncode(attack.toJson()),
    );
  }
}
