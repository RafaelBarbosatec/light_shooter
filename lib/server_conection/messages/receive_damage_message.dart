import 'package:light_shooter/server_conection/messages/base/message.dart';
import 'package:light_shooter/server_conection/messages/base/message_code.dart';

class ReceiveDamageMessage extends Message {
  final double damage;
  ReceiveDamageMessage(this.damage, {DateTime? date})
      : super(
          op: MessageCodeEnum.receiveDamage.index,
          data: {'1': damage},
          date: date,
        );

  factory ReceiveDamageMessage.fromJson(Map<String, dynamic> json) {
    return ReceiveDamageMessage.fromMessage(Message.fromJson(json));
  }

  factory ReceiveDamageMessage.fromMessage(Message msg) {
    return ReceiveDamageMessage(
      double.tryParse(msg.data['1'].toString()) ?? 0.0,
      date: msg.date,
    );
  }
}
