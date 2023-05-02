import 'dart:convert';

import 'package:bonfire/bonfire.dart';
import 'package:light_shooter/game/remote_player/remote_breaker.dart';
import 'package:light_shooter/server_conection/messages/attack_message.dart';
import 'package:light_shooter/shared/enum/operation_code.dart';
// ignore: depend_on_referenced_packages
import 'package:nakama/nakama.dart';

mixin RemoteBreakerControl on SimpleEnemy {
  Direction? _remoteDirection;
  RemoteBreaker get breaker => this as RemoteBreaker;
  @override
  void onMount() {
    breaker.websocketClient.addOnMatchDataObserser(_onDataObserver);
    super.onMount();
  }

  _onDataObserver(MatchData data) {
    if (data.presence.userId == breaker.id) {
      switch (OperationCodeEnum.values[data.opCode]) {
        case OperationCodeEnum.leaderVode:
          break;
        case OperationCodeEnum.movement:
          _handleMoveOp(data.data);
          break;
        case OperationCodeEnum.attack:
          _handleAttackOp(data.data);
          break;
      }
    }
  }

  @override
  void update(double dt) {
    switch (_remoteDirection) {
      case Direction.left:
        moveLeft(speed);
        break;
      case Direction.right:
        moveRight(speed);
        break;
      case Direction.up:
        moveUp(speed);
        break;
      case Direction.down:
        moveDown(speed);
        break;
      case Direction.upLeft:
        break;
      case Direction.upRight:
        break;
      case Direction.downLeft:
        break;
      case Direction.downRight:
        break;
      default:
    }
    super.update(dt);
  }

  void _handleMoveOp(List<int> data) {
    String dataString = String.fromCharCodes(data);
    if (dataString == 'idle') {
      _remoteDirection = null;
      idle();
    } else {
      _remoteDirection = Direction.values.firstWhere(
        (element) => element.name == dataString,
      );
    }
  }

  void _handleAttackOp(List<int> data) {
    String dataString = String.fromCharCodes(data);
    final json = jsonDecode(dataString);
    final attack = AttackMessage.fromJson(json);
    breaker.gun?.execShootAndChangeAngle(attack.angle, attack.damage);
  }
}
