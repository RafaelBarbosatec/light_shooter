import 'dart:convert';

import 'package:bonfire/bonfire.dart';
import 'package:light_shooter/game/remote_player/remote_breaker.dart';
import 'package:light_shooter/server_conection/messages/attack_message.dart';
import 'package:light_shooter/server_conection/messages/base/message.dart';
import 'package:light_shooter/server_conection/messages/base/message_code.dart';
import 'package:light_shooter/server_conection/messages/move_message.dart';
import 'package:light_shooter/server_conection/messages/receive_damage_message.dart';
import 'package:light_shooter/shared/util/buffer_delay.dart';
// ignore: depend_on_referenced_packages
import 'package:nakama/nakama.dart';

mixin RemoteBreakerControl on SimpleEnemy {
  late BufferDelay<Message> buffer;
  JoystickMoveDirectional? _remoteDirection;
  RemoteBreaker get breaker => this as RemoteBreaker;
  double gunAngle = 0.0;

  @override
  void onMount() {
    buffer = BufferDelay(80, _listenEventBuffer);
    breaker.websocketClient.addOnMatchDataObserser(_onDataObserver);
    super.onMount();
  }

  @override
  void die() {
    breaker.websocketClient.removeOnMatchDataObserser(_onDataObserver);
    super.die();
  }

  void _onDataObserver(MatchData data) {
    String dataString = String.fromCharCodes(data.data);
    final json = jsonDecode(dataString);
    Message m = Message.fromJson(json);
    buffer.add(m, m.date);
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
    breaker.gun?.changeLerpAngle(gunAngle, dt);
    super.update(dt);
  }

  void _listenEventBuffer(Message value) {
    switch (MessageCodeEnum.values[value.op]) {
      case MessageCodeEnum.movement:
        _doMove(value);
        break;
      case MessageCodeEnum.attack:
        _doAttack(value);
        break;
      case MessageCodeEnum.die:
        if (!isDead) {
          die();
        }
        break;
      case MessageCodeEnum.receiveDamage:
        _doReceiveDamage(value);
        break;
    }
  }

  void _doMove(Message value) {
    final move = MoveMessage.fromMessage(value);
    _remoteDirection = JoystickMoveDirectional.values.firstWhere(
      (element) => element.name == move.direction,
    );
    speed = move.speed;
    position = move.position;
  }

  void _doAttack(Message value) {
    final attack = AttackMessage.fromMessage(value);
    gunAngle = breaker.gun?.calculeNewAngle(attack.angle) ?? 0.0;
    if (attack.damage > 0) {
      breaker.gun?.execShoot(attack.angle, attack.damage);
    }
  }

  void _doReceiveDamage(Message value) {
    final msg = ReceiveDamageMessage.fromMessage(value);
    removeLife(msg.damage);
  }
}
