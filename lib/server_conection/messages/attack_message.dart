class AttackMessage {
  final double damage;
  final String type;
  final double angle;

  AttackMessage(this.damage, this.type, this.angle);

  factory AttackMessage.fromJson(Map<String, dynamic> json) {
    return AttackMessage(
      double.tryParse(json['1'].toString()) ?? 0.0,
      json['2'],
      double.tryParse(json['3'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '1': damage,
      '2': type,
      '3': angle,
    };
  }
}
