import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:light_shooter/game/player/breaker.dart';
import 'package:light_shooter/game/remote_player/remote_breaker.dart';
import 'package:light_shooter/game/util/player_spritesheet.dart';

class BulletCapsule extends GameComponent
    with UseSpriteAnimation, Movement, BlockMovementCollision, HandleForces {
  bool removing = false;

  BulletCapsule(Vector2 position, double angle) {
    this.angle = angle;
    this.angle = angle;
    this.position = position - Vector2.all(8);
    size = Vector2.all(16);
    speed = 100;
    addForce(
      ResistanceForce2D(
        id: 'id',
        value: Vector2.all(Random().nextDouble() * 2 + 3),
      ),
    );
  }

  @override
  Future<void>? onLoad() async {
    setAnimation(await PlayerSpriteSheet.bulletCapsule);
    await add(
      RectangleHitbox(
        size: Vector2(5, 6),
        position: Vector2.all(6),
      ),
    );
    moveFromAngle(angle);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!removing && isStopped()) {
      removing = true;
      _removeCapsule();
    }
    super.update(dt);
  }

  @override
  bool onBlockMovement(Set<Vector2> intersectionPoints, GameComponent other) {
    if (other is Breaker || other is RemoteBreaker || other is BulletCapsule) {
      return false;
    }
    return super.onBlockMovement(intersectionPoints, other);
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
          startDelay: 1,
        ),
        onComplete: removeFromParent,
      ),
    );
  }
}
