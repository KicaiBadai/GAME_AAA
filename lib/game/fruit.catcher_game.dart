import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'components/basket.dart';
import 'components/fruit.dart';
import 'managers/audio_manager.dart';

class FruitCatcherGame extends FlameGame
    with HasCollisionDetection, PanDetector {
  final void Function(int) onGameOver;

  FruitCatcherGame({required this.onGameOver});

  final Random random = Random();

  int score = 0;
  int life = 3;
  int level = 1;

  double spawnRate = 1;
  double speed = 200;

  late TimerComponent timer;
  late TextComponent hud;

  double cloudOffset = 0;

  @override
  Future<void> onLoad() async {
    final basket = Basket()..position = Vector2(size.x / 2, size.y - 60);
    add(basket);

    hud = TextComponent(
      position: Vector2(12, 12),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
    );

    add(hud);

    timer = TimerComponent(period: spawnRate, repeat: true, onTick: spawnFruit)
      ..timer.start();

    add(timer);

    updateHud();
    AudioManager().playBackgroundMusic();
  }

  void spawnFruit() {
    final x = random.nextDouble() * (size.x - 40) + 20;
    add(Fruit(position: Vector2(x, -30), speed: speed));
  }

  void addScore(Vector2 pos) {
    score++;
    if (score % 10 == 0) levelUp();

    add(FloatingText(text: '+1', position: pos, color: Colors.green));
    AudioManager().playSfx('collect.mp3');
    updateHud();
  }

  void missFruit(Vector2 pos) {
    life--;
    add(FloatingText(text: '-1', position: pos, color: Colors.red));

    if (life <= 0) {
      pauseEngine();
      onGameOver(score);
    }
    updateHud();
  }

  void levelUp() {
    level++;
    speed += 60;
    spawnRate = max(0.35, spawnRate - 0.1);

    timer.timer.limit = spawnRate;
    timer.timer.start();
  }

  void updateHud() {
    hud.text = 'Score: $score   ❤️ $life   Lv: $level';
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    final basket = children.whereType<Basket>().first;

    basket.position.x += info.delta.global.x;
    basket.position.x = basket.position.x.clamp(
      basket.size.x / 2,
      size.x - basket.size.x / 2,
    );
  }

  @override
  void update(double dt) {
    cloudOffset += 12 * dt;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF4FC3F7), Color(0xFFE1F5FE)],
      ).createShader(rect);

    canvas.drawRect(rect, bgPaint);

    final cloudPaint = Paint()..color = Colors.white.withOpacity(0.15);

    void drawCloud(double x, double y, double scale) {
      canvas.drawCircle(Offset(x, y), 28 * scale, cloudPaint);
      canvas.drawCircle(
        Offset(x + 30 * scale, y + 6 * scale),
        24 * scale,
        cloudPaint,
      );
      canvas.drawCircle(
        Offset(x - 30 * scale, y + 6 * scale),
        24 * scale,
        cloudPaint,
      );
    }

    drawCloud((size.x * 0.2 + cloudOffset) % size.x, size.y * 0.18, 1);
    drawCloud((size.x * 0.7 + cloudOffset * 0.6) % size.x, size.y * 0.28, 1.2);
    drawCloud((size.x * 0.4 + cloudOffset * 0.8) % size.x, size.y * 0.12, 0.9);

    super.render(canvas);
  }
}
