import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../fruit_catcher_game.dart';
import 'basket.dart';

class Fruit extends PositionComponent
    with HasGameRef<FruitCatcherGame>, CollisionCallbacks {
  final double speed;
  late final SpriteComponent sprite;
  final String imagePath;

  Fruit({required super.position, required this.speed})
    : imagePath = _getRandomFruitImage(),
      super(size: Vector2.all(50)) {
    // Inisialisasi sprite
    sprite = SpriteComponent()
      ..size = size
      ..anchor = Anchor.center;
  }

  static String _getRandomFruitImage() {
    final random = Random();
    final List<String> fruits = ['apple.png', 'banana.png', 'ngok.png'];
    return fruits[random.nextInt(fruits.length)];
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    anchor = Anchor.center;

    try {
      // Load sprite dengan try-catch
      sprite.sprite = await Sprite.load(imagePath);
      print('✅ Fruit loaded: $imagePath at position $position');
    } catch (e) {
      print('❌ Failed to load $imagePath: $e');
      // Fallback: gambar lingkaran jika gagal load
      sprite = SpriteComponent()
        ..size = size
        ..anchor = Anchor.center;
    }

    add(sprite);
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Gerakan ke bawah
    position.y += speed * dt;

    // Cek apakah fruit keluar layar
    if (position.y > gameRef.size.y + size.y) {
      print('🍎 Fruit missed at ${position.y}');
      gameRef.missFruit(position.clone());
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    if (other is Basket) {
      print('🎯 Fruit caught!');
      gameRef.addScore(position.clone());
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    // Jika sprite gagal load, gambar lingkaran sebagai fallback
    if (sprite.sprite == null) {
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x / 2,
        Paint()..color = Colors.orange,
      );
    }
    super.render(canvas);
  }
}
