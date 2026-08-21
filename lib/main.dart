import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const CriczoApp());
}

class CriczoApp extends StatelessWidget {
  const CriczoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CRICZO',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFF031E13),
      ),
      home: const CriczoGame(),
    );
  }
}

class CriczoGame extends StatefulWidget {
  const CriczoGame({super.key});

  @override
  State<CriczoGame> createState() => _CriczoGameState();
}

class _CriczoGameState extends State<CriczoGame>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();

  int score = 0;
  int balls = 0;
  int wickets = 0;

  final int target = 30;
  final int maxBalls = 12;
  final int maxWickets = 3;

  String message = 'CHOOSE YOUR SHOT!';
  String resultText = '';
  bool gameOver = false;
  bool lastWasSix = false;
  int? selectedShot;

  late AnimationController _ballController;

  @override
  void initState() {
    super.initState();

    _ballController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _ballController.dispose();
    super.dispose();
  }

  void playShot(int shot) {
    if (gameOver) return;

    setState(() {
      selectedShot = shot;
      balls++;
    });

    _ballController.forward(from: 0);

    // Cricket challenge logic.
    // Approximately 1 in 6 balls becomes a wicket.
    final bool wicket = _random.nextInt(6) == 0;

    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;

      setState(() {
        if (wicket) {
          wickets++;
          message = 'OUT! 😱';
          lastWasSix = false;
        } else {
          score += shot;
          lastWasSix = shot == 6;

          if (shot == 6) {
            message = 'SIX! 🔥';
          } else if (shot == 4) {
            message = 'FOUR! 🏏';
          } else {
            message = '+$shot RUN';
          }
        }

        selectedShot = null;
      });

      if (score >= target) {
        finishGame(true);
      } else if (balls >= maxBalls || wickets >= maxWickets) {
        finishGame(false);
      }
    });
  }

  void finishGame(bool won) {
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;

      setState(() {
        gameOver = true;
        resultText = won ? 'YOU WIN! 🏆' : 'MATCH OVER';
        message = won
            ? 'Target completed!'
            : 'Try again and beat $target runs!';
      });

      _showResultDialog(won);
    });
  }

  void _showResultDialog(bool won) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0B3B28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  'assets/logo.png',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return const Icon(
                      Icons.sports_cricket,
                      size: 70,
                      color: Colors.white,
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
              Text(
                won ? 'YOU WIN! 🏆' : 'MATCH OVER',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score / $target',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Balls: $balls/$maxBalls\nWickets: $wickets/$maxWickets',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                resetGame();
              },
              icon: const Icon(Icons.refresh),
              label: const Text(
                'PLAY AGAIN',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF19A463),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 15,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      score = 0;
      balls = 0;
      wickets = 0;
      message = 'CHOOSE YOUR SHOT!';
      resultText = '';
      gameOver = false;
      selectedShot = null;
      lastWasSix = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (score / target).clamp(0.0, 1.0);

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF063B25),
                Color(0xFF031E13),
              ],
            ),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 25),
                  child: Column(
                    children: [
                      _buildScoreCard(progress),
                      const SizedBox(height: 18),
                      _buildCricketGround(),
                      const SizedBox(height: 18),
                      _buildMessage(),
                      const SizedBox(height: 18),
                      _buildShotButtons(),
                      const SizedBox(height: 18),
                      _buildStatusButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 18, 8),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.sports_cricket,
                  size: 40,
                  color: Color(0xFF063B25),
                );
              },
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CRICZO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'Quick Cricket Challenge',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: resetGame,
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(double progress) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF062B1C),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'YOUR SCORE',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$score / $target',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF23C77A),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _stat('BALLS', '$balls/$maxBalls'),
              _stat('TARGET', '$target'),
              _stat('WICKETS', '$wickets/$maxWickets'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCricketGround() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF07512E),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 20,
            left: 35,
            right: 35,
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Pitch
          Positioned(
            bottom: 18,
            top: 25,
            child: Container(
              width: 195,
              decoration: BoxDecoration(
                color: const Color(0xFFC89A60),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),

          // Stumps
          Positioned(
            top: 55,
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _stump(),
                    _stump(),
                    _stump(),
                  ],
                ),
                Container(
                  width: 62,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),

          // Cricket ball
          AnimatedBuilder(
            animation: _ballController,
            builder: (context, child) {
              final value = Curves.easeOut.transform(_ballController.value);
              return Positioned(
                bottom: 45 + (value * 115),
                child: Transform.rotate(
                  angle: value * 5,
                  child: child,
                ),
              );
            },
            child: const Text(
              '🏏',
              style: TextStyle(fontSize: 54),
            ),
          ),

          if (lastWasSix)
            const Positioned(
              top: 125,
              child: Text(
                '🔥 SIX! 🔥',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),

          Positioned(
            bottom: 32,
            left: 48,
            child: Transform.rotate(
              angle: -0.65,
              child: const Text(
                '🏏',
                style: TextStyle(fontSize: 50),
              ),
            ),
          ),

          Positioned(
            bottom: 32,
            right: 48,
            child: Transform.rotate(
              angle: 0.65,
              child: const Text(
                '🏏',
                style: TextStyle(fontSize: 50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stump() {
    return Container(
      width: 6,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildMessage() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF173B2B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: message.contains('SIX') || message.contains('FOUR')
              ? const Color(0xFFFFD54F)
              : Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildShotButtons() {
    final shots = [
      {'runs': 1, 'label': 'RUN'},
      {'runs': 2, 'label': 'RUNS'},
      {'runs': 4, 'label': 'FOUR'},
      {'runs': 6, 'label': 'SIX'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 12),
          child: Text(
            'SELECT YOUR SHOT',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Row(
          children: shots.map((item) {
            final int runs = item['runs'] as int;
            final String label = item['label'] as String;

            final bool selected = selectedShot == runs;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: gameOver ? null : () => playShot(runs),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 105,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF1DAE68)
                          : const Color(0xFF1B392D),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: selected
                            ? Colors.white54
                            : Colors.white.withValues(alpha: 0.08),
                        width: selected ? 2 : 1,
                      ),
                      boxShadow: selected
                          ? const [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius: 12,
                                offset: Offset(0, 5),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$runs',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: gameOver
            ? const Color(0xFF137B4C)
            : const Color(0xFF203B30),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        gameOver ? resultText : 'MATCH IN PROGRESS',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: gameOver ? Colors.white : Colors.white54,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
