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
import 'package:light_shooter/shared/util/event_queue.dart';
import 'package:nakama/nakama.dart';

mixin RemoteBreakerControlller on SimpleEnemy {
  WebsocketClient? websocketClient;
  EventQueue<Message> buffer = EventQueue(80);

  RemoteBreaker get remote => this as RemoteBreaker;

  @override
  void onMount() {
    websocketClient = inject();
    buffer.listen = _listenEventBuffer;
    websocketClient?.addOnMatchDataObserser(_onDataObserver);
    super.onMount();
  }

  @override
  void onRemove() {
    buffer.listen = null;
    websocketClient?.removeOnMatchDataObserser(_onDataObserver);
    super.onRemove();
  }

  void _onDataObserver(MatchData data) {
    if (data.presence.userId == remote.id) {
      String dataString = String.fromCharCodes(data.data);
      final json = jsonDecode(dataString);
      Message m = Message.fromJson(json);
      buffer.add(m, m.date);
    }
  }

  @override
  void update(double dt) {
    buffer.run(dt);
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
    Direction? remoteDirection;
    try {
      remoteDirection = Direction.values.firstWhere(
        (element) => element.name == move.direction,
      );
      speed = move.speed;
    } catch (e) {
      //idle
      stopMove(forceIdle: true);
    }
    _execDirection(remoteDirection);

    if (position.distanceTo(move.position) > width / 6) {
      add(MoveEffect.to(move.position, EffectController(duration: 0.2)));
    }
  }

  void _doAttack(Message value) {
    final attack = AttackMessage.fromMessage(value);
    remote.gun?.changeAngle(attack.angle);
    if (attack.damage > 0) {
      remote.gun?.changeAngle(attack.angle);
      remote.gun?.execShoot(attack.damage);
    }
    remote.gun?.changeAngle(0);
  }

  void _doReceiveDamage(Message value) {
    final msg = ReceiveDamageMessage.fromMessage(value);
    showDamage(
      msg.damage,
      config: const TextStyle(fontSize: 14, color: Colors.red),
    );
    removeLife(msg.damage);
  }

  void _execDirection(Direction? remoteDirection) {
    if (remoteDirection != null) {
      moveFromDirection(remoteDirection);
    }
  }
}
