import 'package:light_shooter/server_conection/messages/base/message.dart';
import 'package:light_shooter/server_conection/messages/base/message_code.dart';

class AttackMessage extends Message {
  // ignore: non_constant_identifier_names
  static final CODE = MessageCodeEnum.attack.index;
  final double damage;
  final String type;
  final double angle;

  AttackMessage(this.damage, this.type, this.angle, {DateTime? date})
      : super(
          op: CODE,
          date: date,
          data: {'1': damage, '2': type, '3': angle},
        );

  factory AttackMessage.fromJson(Map<String, dynamic> json) {
    return AttackMessage.fromMessage(Message.fromJson(json));
  }

  factory AttackMessage.fromMessage(Message msg) {
    return AttackMessage(
      double.tryParse(msg.data['1'].toString()) ?? 0.0,
      msg.data['2'],
      double.tryParse(msg.data['3'].toString()) ?? 0.0,
      date: msg.date,
    );
  }
}
