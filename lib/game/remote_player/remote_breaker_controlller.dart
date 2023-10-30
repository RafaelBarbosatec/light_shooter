import 'dart:convert';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:light_shooter/game/remote_player/remote_breaker.dart';
import 'package:light_shooter/server_conection/messages/attack_message.dart';
import 'package:light_shooter/server_conection/messages/base/message.dart';
import 'package:light_shooter/server_conection/messages/base/message_code.dart';
import 'package:light_shooter/server_conection/messages/move_message.dart';
import 'package:light_shooter/server_conection/messages/receive_damage_message.dart';
import 'package:light_shooter/server_conection/websocket_client.dart';
import 'package:light_shooter/shared/bootstrap.dart';
import 'package:light_shooter/shared/util/buffer_delay.dart';
import 'package:nakama/nakama.dart';

mixin RemoteBreakerControlller on SimpleEnemy {
  WebsocketClient? websocketClient;
  EventQueue<Message>? buffer;
  JoystickMoveDirectional? _remoteDirection;

  RemoteBreaker get remote => this as RemoteBreaker;

  @override
  Future<void> onLoad() {
    websocketClient = inject();
    buffer = EventQueue(40);
    buffer?.listen = _listenEventBuffer;
    websocketClient?.addOnMatchDataObserser(_onDataObserver);
    return onLoad();
  }

  @override
  void onRemove() {
    websocketClient?.removeOnMatchDataObserser(_onDataObserver);
    super.onRemove();
  }

  void _onDataObserver(MatchData data) {
    if (data.presence.userId == remote.id) {
      String dataString = String.fromCharCodes(data.data);
      final json = jsonDecode(dataString);
      Message m = Message.fromJson(json);
      buffer?.add(m, m.date);
    }
  }

  @override
  void update(double dt) {
    buffer?.run(dt);
    switch (_remoteDirection) {
      case JoystickMoveDirectional.MOVE_UP:
        moveUp();
        break;
      case JoystickMoveDirectional.MOVE_RIGHT:
        moveRight();
        break;
      case JoystickMoveDirectional.MOVE_DOWN:
        moveDown();
        break;
      case JoystickMoveDirectional.MOVE_LEFT:
        moveLeft();
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

  void _listenEventBuffer(Message value) {
    switch (MessageCodeEnum.values[value.op]) {
      case MessageCodeEnum.movement:
        _doMove(value);
        break;
      case MessageCodeEnum.attack:
        _doAttack(value);
        break;
      case MessageCodeEnum.die:
        if (!(isDead == true)) {
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
    remote.gun?.changeAngle(attack.angle);
    if (attack.damage > 0) {
      remote.gun?.execShoot(attack.angle, attack.damage);
    }
  }

  void _doReceiveDamage(Message value) {
    final msg = ReceiveDamageMessage.fromMessage(value);
    showDamage(
      msg.damage,
      config: const TextStyle(fontSize: 14, color: Colors.red),
    );
    removeLife(msg.damage);
  }
}
