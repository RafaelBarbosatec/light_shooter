import 'dart:convert';

import 'package:bonfire/bonfire.dart';
import 'package:light_shooter/game/remote_player/remote_breaker.dart';
import 'package:light_shooter/server_conection/messages/attack_message.dart';
import 'package:light_shooter/server_conection/messages/base/message.dart';
import 'package:light_shooter/server_conection/messages/base/message_code.dart';
import 'package:light_shooter/server_conection/messages/move_message.dart';
import 'package:light_shooter/server_conection/messages/receive_damage_message.dart';
import 'package:light_shooter/server_conection/websocket_client.dart';
import 'package:light_shooter/shared/util/buffer_delay.dart';
// ignore: depend_on_referenced_packages
import 'package:nakama/nakama.dart';

class RemoteBreakerControlller extends StateController<RemoteBreaker> {
  final WebsocketClient websocketClient;
  late BufferDelay<Message> buffer;
  JoystickMoveDirectional? _remoteDirection;

  RemoteBreakerControlller(this.websocketClient);

  @override
  void onReady(RemoteBreaker component) {
    buffer = BufferDelay(40, _listenEventBuffer);
    websocketClient.addOnMatchDataObserser(_onDataObserver);
    super.onReady(component);
  }

  @override
  void onRemove(RemoteBreaker component) {
    websocketClient.removeOnMatchDataObserser(_onDataObserver);
    super.onRemove(component);
  }

  void _onDataObserver(MatchData data) {
    String dataString = String.fromCharCodes(data.data);
    final json = jsonDecode(dataString);
    Message m = Message.fromJson(json);
    buffer.add(m, m.date);
  }

  @override
  void update(double dt, RemoteBreaker component) {
    buffer.run();
    switch (_remoteDirection) {
      case JoystickMoveDirectional.MOVE_UP:
        component.moveUp(component.speed);
        break;
      case JoystickMoveDirectional.MOVE_RIGHT:
        component.moveRight(component.speed);
        break;
      case JoystickMoveDirectional.MOVE_DOWN:
        component.moveDown(component.speed);
        break;
      case JoystickMoveDirectional.MOVE_LEFT:
        component.moveLeft(component.speed);
        break;
      case JoystickMoveDirectional.IDLE:
        _remoteDirection = null;
        component.idle();
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
        if (!(component?.isDead == true)) {
          component?.die();
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
    component?.speed = move.speed;
    component?.position = move.position;
  }

  void _doAttack(Message value) {
    final attack = AttackMessage.fromMessage(value);
    component?.gun?.changeAngle(attack.angle);
    if (attack.damage > 0) {
      component?.gun?.execShoot(attack.angle, attack.damage);
    }
  }

  void _doReceiveDamage(Message value) {
    final msg = ReceiveDamageMessage.fromMessage(value);
    component?.removeLife(msg.damage);
  }
}
