import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class FloatingText extends TextComponent {
  double lifeTime = 1.0;
  double dy = -50;

  FloatingText({
    required String text,
    required Vector2 position,
    required Color color,
  }) : super(
         text: text,
         position: position,
         anchor: Anchor.center,
         textRenderer: TextPaint(
           style: TextStyle(
             color: color,
             fontSize: 24,
             fontWeight: FontWeight.bold,
             shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
           ),
         ),
       );

  @override
  void update(double dt) {
    super.update(dt);
    lifeTime -= dt;
    if (lifeTime <= 0) {
      removeFromParent();
    }
    position.y += dy * dt;
  }
}
