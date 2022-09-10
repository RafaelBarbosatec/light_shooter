import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:light_shooter/util/player_spritesheet.dart';

class BulletCapsule extends GameComponent
    with UseSpriteAnimation, Movement, ObjectCollision, Acceleration {
  double reduction = 2;
  bool removing = false;

  BulletCapsule(Vector2 position, double angle) {
    this.angle = angle;
    this.position = position - Vector2.all(8);
    size = Vector2.all(16);
    speed = 100;
    reduction = (Random().nextDouble() + 2) * -1;
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Vector2(5, 6),
            align: Vector2.all(6),
          )
        ],
      ),
    );
  }

  @override
  Future<void>? onLoad() async {
    animation = await PlayerSpriteSheet.bulletCapsule;
    return super.onLoad();
  }

  @override
  void onMount() {
    applyAccelerationByAngle(reduction, angle, stopWhenSpeedZero: true);
    super.onMount();
  }

  @override
  void update(double dt) {
    if (speed == 0 && !removing) {
      if (checkInterval('REMOVE_BULLET', 2000, dt, firstCheckIsTrue: false)) {
        _removeCapsule();
      }
    }

    super.update(dt);
  }

  @override
  bool onCollision(GameComponent component, bool active) {
    if (component is TileWithCollision || component is GameDecoration) {
      speed = 0;
      return super.onCollision(component, active);
    } else {
      return false;
    }
  }

  @override
  int get priority => LayerPriority.MAP + 1;

  void _removeCapsule() {
    removing = true;
    add(
      OpacityEffect.fadeOut(
        EffectController(
          duration: 0.1,
          alternate: true,
          repeatCount: 3,
        ),
        onComplete: removeFromParent,
      ),
    );
  }
}
