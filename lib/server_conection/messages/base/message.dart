import 'dart:convert';

class Message {
  DateTime date;
  int op;
  Map<String, dynamic> data;
  Message({
    DateTime? date,
    required this.op,
    required this.data,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      "1": op,
      "2": date.millisecondsSinceEpoch,
      "3": jsonEncode(data),
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      op: json['1'],
      date: DateTime.fromMillisecondsSinceEpoch(json['2']),
      data: jsonDecode(json['3']),
    );
  }
}
