import 'package:flutter/material.dart';
import 'package:light_shooter/pages/login/login_page.dart';

class LoginRoute {
  static const name = '/';

  static Map<String, WidgetBuilder> get builder => {
        name: (context) => const LoginPage(),
      };

  static Future open(BuildContext context) {
    return Navigator.of(context).pushNamedAndRemoveUntil(name,(route) => false,);
  }
}
