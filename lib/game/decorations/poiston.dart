import 'package:bonfire/bonfire.dart';

class Poison extends GameComponent with Sensor {
  static const name = 'poison';
  Poison(Vector2 position, Vector2 size) {
    this.position = position;
    this.size = size;
  }

  @override
  void onContact(GameComponent component) {
    if (component is Attackable) {
      component.removeLife(10);
    }
  }
}
