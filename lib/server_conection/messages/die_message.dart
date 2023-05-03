import 'package:light_shooter/server_conection/messages/base/message.dart';
import 'package:light_shooter/server_conection/messages/base/message_code.dart';

class DieMessage extends Message {
  DieMessage() : super(op: MessageCodeEnum.die.index, data: {});
}
