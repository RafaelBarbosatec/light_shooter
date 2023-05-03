import 'package:bonfire/bonfire.dart';
import 'package:light_shooter/server_conection/messages/base/message.dart';
import 'package:light_shooter/server_conection/messages/base/message_code.dart';

class MoveMessage extends Message {
  // ignore: non_constant_identifier_names
  static final CODE = MessageCodeEnum.movement.index;
  final String direction;
  final double speed;
  final Vector2 position;

  MoveMessage(this.direction, this.position, this.speed, {DateTime? date})
      : super(
          op: CODE,
          date: date,
          data: {
            '1': direction,
            '2': {'x': position.x, 'y': position.y},
            '3': speed,
          },
        );

  factory MoveMessage.fromJson(Map<String, dynamic> json) {
    return MoveMessage.fromMessage(Message.fromJson(json));
  }

  factory MoveMessage.fromMessage(Message msg) {
    var pos = msg.data['2'] as Map;
    return MoveMessage(
      msg.data['1'],
      Vector2(
        double.tryParse(pos['x'].toString()) ?? 0.0,
        double.tryParse(pos['y'].toString()) ?? 0.0,
      ),
      double.tryParse(msg.data['3'].toString()) ?? 0.0,
      date: msg.date,
    );
  }
}
