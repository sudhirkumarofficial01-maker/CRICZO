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
        scaffoldBackgroundColor: const Color(0xFF06271B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981),
          brightness: Brightness.dark,
        ),
      ),
      home: const CricketGame(),
    );
  }
}

class CricketGame extends StatefulWidget {
  const CricketGame({super.key});

  @override
  State<CricketGame> createState() => _CricketGameState();
}

class _CricketGameState extends State<CricketGame> {
  final Random random = Random();

  int score = 0;
  int balls = 0;
  int wickets = 0;

  final int target = 30;

  String message = 'Choose your shot!';
  String lastResult = '';

  bool gameOver = false;
  bool isBatting = false;

  final List<int> shots = [1, 2, 4, 6];

  void playShot(int shot) {
    if (gameOver || isBatting) return;

    setState(() {
      isBatting = true;
      message = 'Playing shot...';
    });

    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;

      final ball = random.nextInt(100);

      int runs = 0;
      bool wicket = false;

      if (ball < 10) {
        wicket = true;
      } else if (ball < 30) {
        runs = 0;
      } else if (shot == 6 && ball < 55) {
        runs = 6;
      } else if (shot == 4 && ball < 65) {
        runs = 4;
      } else if (ball < 80) {
        runs = min(shot, 2);
      } else {
        runs = shot;
      }

      setState(() {
        balls++;
        isBatting = false;

        if (wicket) {
          wickets++;
          lastResult = 'WICKET!';
          message = 'Oh no! You lost a wicket.';
        } else if (runs == 0) {
          lastResult = 'DOT BALL';
          message = 'Good delivery — no run.';
        } else {
          score += runs;

          lastResult =
              '+$runs RUN${runs == 1 ? '' : 'S'}';

          message =
              runs >= 4 ? 'What a shot! 🔥' : 'Nice running!';
        }

        if (score >= target) {
          gameOver = true;
          message = 'YOU WIN! 🏆';
        } else if (balls >= 12 || wickets >= 3) {
          gameOver = true;
          message = 'MATCH OVER';
        }
      });
    });
  }

  void restart() {
    setState(() {
      score = 0;
      balls = 0;
      wickets = 0;
      message = 'Choose your shot!';
      lastResult = '';
      gameOver = false;
      isBatting = false;
    });
  }

  Color buttonColor(int shot) {
    if (shot == 6) {
      return const Color(0xFF15803D);
    }

    if (shot == 4) {
      return const Color(0xFF166534);
    }

    return const Color(0xFF23483A);
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        (score / target).clamp(0.0, 1.0);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            18,
            16,
            18,
            24,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              header(),

              const SizedBox(height: 18),

              scoreCard(progress),

              const SizedBox(height: 18),

              stadium(),

              const SizedBox(height: 14),

              messageCard(),

              const SizedBox(height: 18),

              const Text(
                'SELECT YOUR SHOT',
                style: TextStyle(
                  color: Color(0xFF8FA89D),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: shots.map((shot) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: shot == 6 ? 0 : 8,
                      ),
                      child: shotButton(shot),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              if (lastResult.isNotEmpty)
                Center(
                  child: Text(
                    lastResult,
                    style: const TextStyle(
                      color: Color(0xFFE7FFF3),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

              const SizedBox(height: 14),

              bottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget header() {
    return Row(
      children: [
        const CriczoLogo(size: 58),

        const SizedBox(width: 12),

        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'CRICZO',
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Quick Cricket Challenge',
                style: TextStyle(
                  color: Color(0xFF9BB2A8),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: restart,
          icon: const Icon(
            Icons.refresh_rounded,
            size: 31,
          ),
        ),
      ],
    );
  }

  Widget scoreCard(double progress) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF032217),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF164936),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'YOUR SCORE',
            style: TextStyle(
              color: Color(0xFF9FB5AA),
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.2,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            '$score / $target',
            style: const TextStyle(
              fontSize: 54,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 18),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor:
                  const Color(0xFF173A2E),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(
                Color(0xFF34D399),
              ),
            ),
          ),

          const SizedBox(height: 18),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround,
            children: [
              stat('BALLS', '$balls/12'),
              stat('TARGET', '$target'),
              stat('WICKETS', '$wickets/3'),
            ],
          ),
        ],
      ),
    );
  }

  Widget stat(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF849B90),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFE7F3ED),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget stadium() {
    return Container(
      height: 275,
      decoration: BoxDecoration(
        color: const Color(0xFF07522F),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF0B6B3E),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(
            top: 18,
            left: 22,
            child: Text(
              '🏟️',
              style: TextStyle(fontSize: 38),
            ),
          ),

          const Positioned(
            top: 18,
            right: 22,
            child: Text(
              '🏟️',
              style: TextStyle(fontSize: 38),
            ),
          ),

          Positioned(
            top: 45,
            child: Container(
              width: 150,
              height: 205,
              decoration: BoxDecoration(
                color: const Color(0xFFC99B62),
                borderRadius:
                    BorderRadius.circular(80),
              ),
            ),
          ),

          Positioned(
            bottom: 53,
            child: Container(
              width: 215,
              height: 3,
              color: const Color(0xFF9CB7A9),
            ),
          ),

          const Positioned(
            bottom: 65,
            left: 48,
            child: Text(
              '🏏',
              style: TextStyle(fontSize: 47),
            ),
          ),

          const Positioned(
            bottom: 65,
            right: 48,
            child: Text(
              '🏏',
              style: TextStyle(fontSize: 47),
            ),
          ),

          Text(
            '🏏',
            style: TextStyle(
              fontSize: isBatting ? 68 : 55,
            ),
          ),

          const Positioned(
            bottom: 82,
            child: Text(
              '⚾',
              style: TextStyle(fontSize: 48),
            ),
          ),

          if (gameOver)
            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xEE031C12),
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFF34D399),
                ),
              ),
              child: Text(
                score >= target
                    ? '🏆 YOU WIN!'
                    : '🏏 MATCH OVER',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget messageCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF153A2D),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget shotButton(int shot) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: gameOver || isBatting
            ? null
            : () => playShot(shot),
        child: Ink(
          height: 92,
          decoration: BoxDecoration(
            color: buttonColor(shot),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFF355B4C),
            ),
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Text(
                '$shot',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                shot == 1
                    ? 'RUN'
                    : shot == 2
                        ? 'RUNS'
                        : shot == 4
                            ? 'FOUR'
                            : 'SIX',
                style: const TextStyle(
                  color: Color(0xFFAEC2B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomButton() {
    return SizedBox(
      height: 58,
      child: ElevatedButton(
        onPressed: restart,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              const Color(0xFF1E3D31),
          foregroundColor:
              const Color(0xFFB6C8C0),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
        ),
        child: Text(
          gameOver
              ? 'PLAY AGAIN'
              : 'MATCH IN PROGRESS',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class CriczoLogo extends StatelessWidget {
  final double size;

  const CriczoLogo({
    super.key,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(size * .25),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size * .16,
            left: size * .15,
            child: Text(
              '🏏',
              style: TextStyle(
                fontSize: size * .52,
              ),
            ),
          ),

          Positioned(
            top: size * .12,
            right: size * .10,
            child: Text(
              '🏏',
              style: TextStyle(
                fontSize: size * .34,
              ),
            ),
          ),

          Positioned(
            bottom: size * .10,
            left: size * .12,
            child: Text(
              '⚾',
              style: TextStyle(
                fontSize: size * .24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
