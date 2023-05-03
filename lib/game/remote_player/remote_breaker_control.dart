import 'dart:convert';

import 'package:bonfire/bonfire.dart';
import 'package:light_shooter/game/remote_player/remote_breaker.dart';
import 'package:light_shooter/server_conection/messages/attack_message.dart';
import 'package:light_shooter/server_conection/messages/base/message_code.dart';
import 'package:light_shooter/server_conection/messages/move_message.dart';
// ignore: depend_on_referenced_packages
import 'package:nakama/nakama.dart';

mixin RemoteBreakerControl on SimpleEnemy {
  JoystickMoveDirectional? _remoteDirection;
  RemoteBreaker get breaker => this as RemoteBreaker;
  @override
  void onMount() {
    breaker.websocketClient.addOnMatchDataObserser(_onDataObserver);
    super.onMount();
  }

  _onDataObserver(MatchData data) {
    if (data.presence.sessionId == breaker.id) {
      switch (MessageCodeEnum.values[data.opCode]) {
        case MessageCodeEnum.leaderVode:
          break;
        case MessageCodeEnum.movement:
          _handleMoveOp(data.data);
          break;
        case MessageCodeEnum.attack:
          _handleAttackOp(data.data);
          break;
      }
    }
  }

  @override
  void update(double dt) {
    switch (_remoteDirection) {
      case JoystickMoveDirectional.MOVE_UP:
        moveUp(speed);
        break;
      case JoystickMoveDirectional.MOVE_RIGHT:
        moveRight(speed);
        break;
      case JoystickMoveDirectional.MOVE_DOWN:
        moveDown(speed);
        break;

      case JoystickMoveDirectional.MOVE_LEFT:
        moveLeft(speed);
        break;
      case JoystickMoveDirectional.IDLE:
        _remoteDirection = null;
        idle();
        break;
      case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
        break;
      case JoystickMoveDirectional.MOVE_DOWN_LEFT:
        break;
      case JoystickMoveDirectional.MOVE_UP_LEFT:
        break;
      case JoystickMoveDirectional.MOVE_UP_RIGHT:
        break;
      default:
    }
    super.update(dt);
  }

  void _handleMoveOp(List<int> data) {
    String dataString = String.fromCharCodes(data);
    final json = jsonDecode(dataString);
    final move = MoveMessage.fromJson(json);
    print(move.toJson());
    _remoteDirection = JoystickMoveDirectional.values.firstWhere(
      (element) => element.name == move.direction,
    );
    speed = move.speed;
  }

  void _handleAttackOp(List<int> data) {
    String dataString = String.fromCharCodes(data);
    final json = jsonDecode(dataString);
    final attack = AttackMessage.fromJson(json);
    breaker.gun?.changeAngle(attack.angle);
    if (attack.damage > 0) {
      breaker.gun?.execShoot(attack.angle, attack.damage);
    }
  }

  @override
  void die() {
    breaker.websocketClient.removeOnMatchDataObserser(_onDataObserver);
    super.die();
  }
}
