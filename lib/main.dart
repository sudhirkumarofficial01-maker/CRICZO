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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF071B12),
        useMaterial3: true,
      ),
      home: const CriczoHome(),
    );
  }
}

class CriczoHome extends StatefulWidget {
  const CriczoHome({super.key});

  @override
  State<CriczoHome> createState() => _CriczoHomeState();
}

class _CriczoHomeState extends State<CriczoHome> {
  final Random random = Random();

  int score = 0;
  int wickets = 0;
  int balls = 0;
  int target = 0;

  bool gameStarted = false;
  bool gameOver = false;
  bool won = false;

  String message = 'Tap START MATCH';

  final List<int> runs = [0, 1, 2, 3, 4, 6];

  void startGame() {
    setState(() {
      score = 0;
      wickets = 0;
      balls = 0;
      target = 0;
      gameStarted = true;
      gameOver = false;
      won = false;
      message = 'Choose your shot!';
    });
  }

  void playShot(int shot) {
    if (!gameStarted || gameOver) return;

    final int ballResult = runs[random.nextInt(runs.length)];

    setState(() {
      balls++;

      // Small chance of wicket
      if (random.nextInt(10) == 0) {
        wickets++;
        message = 'OUT! 😱';
      } else {
        int actualRuns = shot;

        // If shot is too aggressive, sometimes it becomes a different result.
        if (random.nextInt(10) < 2) {
          actualRuns = ballResult;
        }

        score += actualRuns;

        if (actualRuns == 6) {
          message = 'SIX! 🔥';
        } else if (actualRuns == 4) {
          message = 'FOUR! 🏏';
        } else if (actualRuns == 0) {
          message = 'Dot Ball!';
        } else {
          message = '$actualRuns Run${actualRuns == 1 ? '' : 's'}';
        }
      }

      if (score >= 30) {
        gameOver = true;
        won = true;
        message = 'YOU WIN! 🏆';
      } else if (wickets >= 3 || balls >= 12) {
        gameOver = true;
        won = false;
        message = 'MATCH OVER';
      }
    });
  }

  void resetGame() {
    setState(() {
      score = 0;
      wickets = 0;
      balls = 0;
      target = 0;
      gameStarted = false;
      gameOver = false;
      won = false;
      message = 'Tap START MATCH';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0B3D25),
                Color(0xFF071B12),
              ],
            ),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _buildScoreBoard(),
                      const SizedBox(height: 18),
                      _buildStadium(),
                      const SizedBox(height: 20),
                      _buildMessage(),
                      const SizedBox(height: 18),
                      _buildShotButtons(),
                      const SizedBox(height: 20),
                      _buildStartButton(),
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
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text(
                '🏏',
                style: TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CRICZO',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'Quick Cricket Challenge',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: resetGame,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBoard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.25),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(.10),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'YOUR SCORE',
            style: TextStyle(
              color: Colors.white60,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$score / $wickets',
            style: const TextStyle(
              fontSize: 46,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _stat('BALLS', '$balls/12'),
              _stat('TARGET', '30'),
              _stat('WICKETS', '$wickets/3'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildStadium() {
    return Container(
      height: 190,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const RadialGradient(
          colors: [
            Color(0xFF37A35A),
            Color(0xFF176B37),
            Color(0xFF0D4325),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 165,
            decoration: BoxDecoration(
              color: const Color(0xFFC79B62),
              borderRadius: BorderRadius.circular(60),
            ),
          ),
          Positioned(
            top: 16,
            child: Text(
              '🏟️',
              style: TextStyle(
                fontSize: 44,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(.35),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            bottom: 26,
            child: Text(
              '🏏   ⚾   🏏',
              style: TextStyle(fontSize: 28),
            ),
          ),
          Positioned(
            bottom: 7,
            child: Container(
              width: 150,
              height: 3,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 18,
      ),
      decoration: BoxDecoration(
        color: won
            ? Colors.green.withOpacity(.25)
            : Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: won ? Colors.greenAccent : Colors.white,
        ),
      ),
    );
  }

  Widget _buildShotButtons() {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'SELECT YOUR SHOT',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _shotButton(1, '1', 'RUN')),
            const SizedBox(width: 10),
            Expanded(child: _shotButton(2, '2', 'RUNS')),
            const SizedBox(width: 10),
            Expanded(child: _shotButton(4, '4', 'FOUR')),
            const SizedBox(width: 10),
            Expanded(child: _shotButton(6, '6', 'SIX')),
          ],
        ),
      ],
    );
  }

  Widget _shotButton(int value, String number, String label) {
    return InkWell(
      onTap: () => playShot(value),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(.12),
          ),
        ),
        child: Column(
          children: [
            Text(
              number,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: gameOver || !gameStarted ? startGame : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFC107),
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.white12,
          disabledForegroundColor: Colors.white38,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          !gameStarted
              ? 'START MATCH 🏏'
              : gameOver
                  ? 'PLAY AGAIN 🔄'
                  : 'MATCH IN PROGRESS',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
