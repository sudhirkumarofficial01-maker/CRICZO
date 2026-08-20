import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const CriczoApp());

class CriczoApp extends StatelessWidget {
  const CriczoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Criczo',
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF061B2E),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFFB300),
        brightness: Brightness.dark,
      ),
    ),
    home: const HomeScreen(),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int coins = 0, best = 0;

  @override void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      coins = p.getInt('coins') ?? 0;
      best = p.getInt('best') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF082B49), Color(0xFF03111E)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset('assets/criczo_icon.png',
                    width: 190, height: 190, fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
              const Text('CRICZO', style: TextStyle(
                fontSize: 44, fontWeight: FontWeight.w900,
                letterSpacing: 2, color: Color(0xFFFFC107))),
              const Text('Tap. Hit. Score!',
                  style: TextStyle(fontSize: 17, color: Colors.white70)),
              const SizedBox(height: 28),
              Row(children: [
                stat('BEST', '$best', Icons.emoji_events),
                const SizedBox(width: 12),
                stat('COINS', '$coins', Icons.monetization_on),
              ]),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 58,
                child: FilledButton.icon(
                  onPressed: () async {
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const GameScreen()));
                    load();
                  },
                  icon: const Icon(Icons.sports_cricket, size: 28),
                  label: const Text('PLAY NOW',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 14),
              const Text('1 over • Offline • No account required',
                  style: TextStyle(color: Colors.white54)),
            ]),
          ),
        ),
      ),
    ),
  );

  Widget stat(String title, String value, IconData icon) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(children: [
        Icon(icon, color: const Color(0xFFFFC107)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(title, style: const TextStyle(color: Colors.white54)),
      ]),
    ),
  );
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final rng = Random();
  int score = 0, wickets = 0, balls = 0, coins = 0, level = 1;
  String message = 'GET READY!';
  bool busy = false;
  int? lastRuns;

  Future<void> bat() async {
    if (busy || balls >= 6 || wickets >= 2) return;
    setState(() { busy = true; message = 'BOWLER RUNNING...'; lastRuns = null; });
    await Future.delayed(const Duration(milliseconds: 450));

    final r = rng.nextInt(100);
    final wicketChance = min(18, 8 + level * 2);
    int runs;
    if (r < wicketChance) runs = -1;
    else if (r < 30) runs = 0;
    else if (r < 52) runs = 1;
    else if (r < 68) runs = 2;
    else if (r < 91) runs = 4;
    else runs = 6;

    setState(() {
      balls++;
      busy = false;
      if (runs == -1) {
        wickets++;
        message = 'WICKET! 😱';
      } else {
        score += runs;
        lastRuns = runs;
        if (runs == 6) { message = 'SIX! 🔥'; coins += 3; }
        else if (runs == 4) { message = 'FOUR! 🏏'; coins += 2; }
        else if (runs == 0) message = 'DOT BALL';
        else { message = '$runs RUN'; coins++; }
      }
    });

    if (balls >= 6 || wickets >= 2) finish();
  }

  Future<void> finish() async {
    await Future.delayed(const Duration(milliseconds: 600));
    final p = await SharedPreferences.getInstance();
    final oldBest = p.getInt('best') ?? 0;
    final oldCoins = p.getInt('coins') ?? 0;
    await p.setInt('best', max(oldBest, score));
    await p.setInt('coins', oldCoins + coins);
    if (!mounted) return;

    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(score >= 18 ? 'YOU WON! 🏆' : 'INNINGS OVER'),
        content: Text('Score: $score runs\nWickets: $wickets\nCoins earned: $coins'),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); resetGame(); },
              child: const Text('PLAY AGAIN')),
          FilledButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              child: const Text('HOME')),
        ],
      ),
    );
  }

  void resetGame() => setState(() {
    score = 0; wickets = 0; balls = 0; coins = 0;
    level = min(20, level + 1); message = 'GET READY!'; lastRuns = null;
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Criczo'),
      backgroundColor: Colors.transparent,
      actions: [Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Center(child: Text('🪙 $coins',
            style: const TextStyle(fontWeight: FontWeight.bold))),
      )],
    ),
    body: SafeArea(child: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Row(children: [
          box('SCORE', '$score/$wickets'),
          const SizedBox(width: 10), box('OVER', '$balls/6'),
          const SizedBox(width: 10), box('LEVEL', '$level'),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(minHeight: 8, value: balls / 6,
              backgroundColor: Colors.white10),
        ),
      ),
      const SizedBox(height: 18),
      Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [Color(0xFF0D4A45), Color(0xFF06251F)],
              begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
          child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🏟️', style: TextStyle(fontSize: 58)),
            const Text('🏏', style: TextStyle(fontSize: 88)),
            Text(message, style: const TextStyle(
              fontSize: 26, fontWeight: FontWeight.w900)),
            if (lastRuns != null)
              Text('$lastRuns', style: const TextStyle(
                fontSize: 72, fontWeight: FontWeight.w900)),
          ])),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        child: SizedBox(
          width: double.infinity, height: 66,
          child: FilledButton.icon(
            onPressed: busy ? null : bat,
            icon: const Icon(Icons.sports_cricket, size: 30),
            label: Text(busy ? 'WAIT...' : 'TAP TO BAT',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          ),
        ),
      ),
    ])),
  );

  Widget box(String label, String value) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
      ]),
    ),
  );
}
