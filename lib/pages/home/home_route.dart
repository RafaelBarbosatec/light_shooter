import 'package:flutter/material.dart';
import 'package:light_shooter/pages/home/home_page.dart';

class HomeRoute {
  static const name = '/home';

  static Map<String, WidgetBuilder> get builder => {
        name: (context) => const HomePage(),
      };

  static Future open(BuildContext context) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
      name,
      (route) => false,
    );
  }
}
