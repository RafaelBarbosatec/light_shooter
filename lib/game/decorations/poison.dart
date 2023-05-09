import 'package:bonfire/bonfire.dart';
import 'package:light_shooter/game/player/breaker.dart';

class Poison extends GameComponent with Sensor {
  static const name = 'poison';
  Poison(Vector2 position, Vector2 size) {
    this.position = position;
    this.size = size;
  }

  @override
  void onContact(GameComponent component) {
    if (component is Breaker) {
      component.removeLife(10);
    }
  }
}
