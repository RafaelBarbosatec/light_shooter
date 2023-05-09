import 'package:light_shooter/server_conection/messages/base/message.dart';
import 'package:light_shooter/server_conection/messages/base/message_code.dart';

class DieMessage extends Message {
  DieMessage({DateTime? date})
      : super(
          op: MessageCodeEnum.die.index,
          data: {},
          date: date,
        );
}
