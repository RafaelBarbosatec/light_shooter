import 'dart:convert';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:light_shooter/game/player/weapons/breaker_cannon.dart';
import 'package:light_shooter/game/remote_player/remote_breaker.dart';
import 'package:light_shooter/game/util/player_spritesheet.dart';
import 'package:light_shooter/server_conection/messages/attack_message.dart';
import 'package:light_shooter/server_conection/messages/base/message.dart';
import 'package:light_shooter/server_conection/messages/die_message.dart';
import 'package:light_shooter/server_conection/messages/move_message.dart';
import 'package:light_shooter/server_conection/messages/receive_damage_message.dart';
import 'package:light_shooter/server_conection/websocket_client.dart';

class Breaker extends SimplePlayer
    with BlockMovementCollision, MouseEventListener, Lighting, ChangeNotifier {
  static const double maxLive = 100;
  BreakerCannon? gun;
  final Color flashDamage = Colors.red;
  final bool enabledMouse;
  double gunDamage = 25;
  WebsocketClient websocketClient;
  JoystickMoveDirectional? lastSocketDirection;
  final PlayerColor color;
  final String name;
  final lineGunPaint = Paint()
    ..color = Colors.blue.withOpacity(0.2)
    ..strokeWidth = 3;
  Breaker({
    required super.position,
    required this.websocketClient,
    required this.color,
    this.name = '',
    this.enabledMouse = false,
  }) : super(
          size: Vector2.all(64),
          animation: PlayerSpriteSheet.animation(color),
          speed: 60,
          life: maxLive,
        ) {
    enableMouseGesture = false;
    setupMovementByJoystick(diagonalEnabled: false);
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
  void render(Canvas canvas) {
    if (gun?.radAngle != 0) {
      final p1 = gun!.center.toOffset();
      final p2 = BonfireUtil.movePointByAngle(gun!.center, 800, gun!.radAngle)
          .toOffset();

      canvas.drawLine(p1, p2, lineGunPaint);
    }
    super.render(canvas);
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (event.id == 1) {
      if (event.event == ActionEvent.MOVE) {
        gun?.changeAngle(event.radAngle);
      }
      if (event.event == ActionEvent.UP) {
        if (gun?.reloading == false) {
          gun?.execShoot(gunDamage);
          _sendShootMessage(gun!.radAngle, gunDamage);
        }
        gun?.changeAngle(0);
      }
    }
    if (event.id == 2 && event.event == ActionEvent.DOWN) {
      gun?.reload();
    }
    super.onJoystickAction(event);
  }

  @override
  void onJoystickChangeDirectional(JoystickDirectionalEvent event) {
    if (event.directional != lastSocketDirection) {
      lastSocketDirection = event.directional;
      sendMessage(MoveMessage(event.directional.name, position, speed));
    }
    super.onJoystickChangeDirectional(event);
  }

  @override
  void onMount() {
    add(gun = BreakerCannon(Vector2(32, 44), color));
    super.onMount();
  }

  @override
  void removeLife(double life) {
    gameRef.colorFilter?.config.color = flashDamage;
    gameRef.colorFilter?.animateTo(Colors.transparent);
    sendMessage(ReceiveDamageMessage(life));
    showDamage(
      life,
      config: const TextStyle(fontSize: 14, color: Colors.red),
    );
    super.removeLife(life);
    notifyListeners();
  }

  @override
  void onMouseTap(MouseButton button) {}

  @override
  void onMouseScreenTapDown(int pointer, Vector2 position, MouseButton button) {
    var angle = BonfireUtil.angleBetweenPoints(
      gun?.absoluteCenter ?? absoluteCenter,
      gameRef.screenToWorld(position),
    );
    if (gun?.reloading == false) {
      gun?.execShoot(gunDamage);
      _sendShootMessage(angle, gunDamage);
    }
    super.onMouseScreenTapDown(pointer, position, button);
  }

  @override
  void onMouseHoverScreen(int pointer, Vector2 position) {
    double angle = BonfireUtil.angleBetweenPoints(
      gun?.absoluteCenter ?? absoluteCenter,
      gameRef.screenToWorld(position),
    );
    gun?.changeAngle(angle);
    super.onMouseHoverScreen(pointer, position);
  }

  @override
  bool onBlockMovement(Set<Vector2> intersectionPoints, GameComponent other) {
    if (other is RemoteBreaker) {
      return false;
    }
    return super.onBlockMovement(intersectionPoints, other);
  }

  void _sendShootMessage(double angle, damage) {
    sendMessage(AttackMessage(damage, 'cannon', angle));
  }

  void sendMessage(Message m) {
    websocketClient.sendMatchData(
      m.op,
      jsonEncode(m.toJson()),
    );
  }

  @override
  void die() {
    sendMessage(DieMessage());
    animation?.playOnce(
      PlayerSpriteSheet.die(color),
      onFinish: removeFromParent,
    );
    super.die();
  }
}
