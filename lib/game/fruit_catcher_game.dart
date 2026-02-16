import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'components/basket.dart';
import 'components/fruit.dart';
import 'managers/audio_manager.dart';
import 'floating_text.dart';

class FruitCatcherGame extends FlameGame
    with PanDetector, HasCollisionDetection {
  FruitCatcherGame();

  late Basket basket;
  late TextComponent scoreText;
  final Random random = Random();
  double fruitSpawnTimer = 0;
  double fruitSpawnInterval = 1.5;

  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> gameOverNotifier = ValueNotifier<bool>(false);

  int _score = 0;
  int get score => _score;
  set score(int value) {
    _score = value;
    scoreNotifier.value = value;
  }

  int life = 3;
  int level = 1;
  double speed = 200;

  final AudioManager audioManager = AudioManager();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    print('Game size: $size');

    // Add basket di tengah bawah
    basket = Basket();
    basket.position = Vector2(size.x / 2, size.y - 60);
    await add(basket);

    // Add score text component
    scoreText = TextComponent(
      text: 'Score: 0   ❤️ 3   Lv: 1',
      position: Vector2(10, 10),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
    );
    await add(scoreText);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Spawn fruits
    fruitSpawnTimer += dt;
    if (fruitSpawnTimer >= fruitSpawnInterval) {
      spawnFruit();
      fruitSpawnTimer = 0;
    }
  }

  void spawnFruit() {
    final x = random.nextDouble() * (size.x - 40) + 20;
    final fruit = Fruit(position: Vector2(x, -30), speed: speed);
    add(fruit);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    basket.position.x += info.delta.global.x;
    basket.position.x = basket.position.x.clamp(
      basket.size.x / 2,
      size.x - basket.size.x / 2,
    );
  }

  void addScore(Vector2 pos) {
    score++;

    if (score % 10 == 0) {
      levelUp();
    }

    scoreText.text = 'Score: $score   ❤️ $life   Lv: $level';
    add(FloatingText(text: '+1', position: pos, color: Colors.green));
    audioManager.playSfx('collect.mp3');
  }

  void missFruit(Vector2 pos) {
    life--;

    add(FloatingText(text: '-1', position: pos, color: Colors.red));
    scoreText.text = 'Score: $score   ❤️ $life   Lv: $level';

    if (life <= 0) {
      gameOver();
    }
  }

  void levelUp() {
    level++;
    speed += 60;
    fruitSpawnInterval = max(0.35, fruitSpawnInterval - 0.1);
  }

  void gameOver() {
    if (gameOverNotifier.value) return;

    audioManager.playSfx('explosion.mp3');

    // Panggil pause tanpa menunggu (fire-and-forget)
    audioManager.pauseBackgroundMusic();

    gameOverNotifier.value = true;
    pauseEngine();
  }

  void resetGame() {
    _score = 0;
    life = 3;
    level = 1;
    speed = 200;
    fruitSpawnInterval = 1.5;
    fruitSpawnTimer = 0;

    scoreNotifier.value = 0;
    gameOverNotifier.value = false;

    // Hapus semua fruit
    children.whereType<Fruit>().forEach((fruit) {
      fruit.removeFromParent();
    });

    basket.position = Vector2(size.x / 2, size.y - 60);
    scoreText.text = 'Score: 0   ❤️ 3   Lv: 1';

    resumeEngine();

    // 🔥 PERBAIKAN: Beri jeda sebelum play musik lagi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      audioManager.playBackgroundMusic();
    });
  }

  @override
  void onRemove() {
    audioManager.dispose();
    scoreNotifier.dispose();
    gameOverNotifier.dispose();
    super.onRemove();
  }

  @override
  Color backgroundColor() => const Color(0xFF87CEEB);
}
