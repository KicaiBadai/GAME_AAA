import 'package:flutter/material.dart';
import 'package:flame/game.dart';

import 'game/fruit_catcher_game.dart';
import 'game/managers/audio_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize audio - otomatis play musik
  await AudioManager().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late FruitCatcherGame game;
  final AudioManager audioManager = AudioManager();

  @override
  void initState() {
    super.initState();
    game = FruitCatcherGame();

    // Listener untuk game over
    game.gameOverNotifier.addListener(_onGameOver);
  }

  void _onGameOver() {
    if (game.gameOverNotifier.value) {
      setState(() {});
    }
  }

  void restartGame() {
    // Hanya set state, urusan audio sudah di handle di game.resetGame()
    setState(() {
      game.resetGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Game widget full screen
          SizedBox.expand(child: GameWidget(game: game)),

          // Tombol music & sfx
          Positioned(
            top: 40,
            right: 20,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    audioManager.isMusicEnabled
                        ? Icons.music_note
                        : Icons.music_off,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () async {
                    // Toggle music dengan async/await
                    await audioManager.toggleMusic();
                    setState(() {});
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    audioManager.isSfxEnabled
                        ? Icons.volume_up
                        : Icons.volume_off,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () {
                    setState(() {
                      audioManager.toggleSfx();
                    });
                  },
                ),
              ],
            ),
          ),

          // Score display
          Positioned(
            top: 40,
            left: 20,
            child: ValueListenableBuilder<int>(
              valueListenable: game.scoreNotifier,
              builder: (context, score, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Score: $score',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),

          // Game Over Overlay
          ValueListenableBuilder<bool>(
            valueListenable: game.gameOverNotifier,
            builder: (context, isGameOver, child) {
              if (!isGameOver) return const SizedBox.shrink();

              return Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'GAME OVER',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Final Score: ${game.score}',
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.yellow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: restartGame,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                        ),
                        child: const Text('PLAY AGAIN'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    game.gameOverNotifier.removeListener(_onGameOver);
    game.onRemove();
    super.dispose();
  }
}
