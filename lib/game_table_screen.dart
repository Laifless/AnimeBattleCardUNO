import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

enum CardType { normal, legendary }

class AnimeCard {
  final String name;
  final Color color;
  final String value;
  final CardType type;
  AnimeCard({required this.name, required this.color, required this.value, this.type = CardType.normal});
}

class GameTableScreen extends StatefulWidget {
  final String roomId;
  final String universe;
  final String battleCry;
  final String characterGifUrl;

  const GameTableScreen({super.key, required this.roomId, required this.universe, required this.battleCry, required this.characterGifUrl});

  @override
  State<GameTableScreen> createState() => _GameTableScreenState();
}

class _GameTableScreenState extends State<GameTableScreen> {
  List<AnimeCard> myHand = [];
  List<AnimeCard> opponentHand = [];
  List<AnimeCard> drawPile = [];
  AnimeCard? lastPlayedCard;
  bool isMyTurn = true;
  Timer? _turnTimer;
  int _secondsLeft = 15;
  bool _ultimateShouted = false;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  @override
  void dispose() {
    _turnTimer?.cancel();
    super.dispose();
  }

  void _setupGame() {
    _turnTimer?.cancel();
    drawPile = _generateActionDeck();
    setState(() {
      myHand = List.generate(7, (_) => drawPile.removeLast());
      opponentHand = List.generate(7, (_) => drawPile.removeLast());
      lastPlayedCard = drawPile.removeLast();
      isMyTurn = true;
      _ultimateShouted = false;
    });
    _startTimer();
  }

  List<AnimeCard> _generateActionDeck() {
    List<AnimeCard> deck = [];
    List<Color> cols = [Colors.red, Colors.blue, Colors.green, Colors.orange];
    List<String> names = ["Hachiman", "Fuutarou", "Kazuya", "Nasa", "Ryuuji", "Takeo", "Miyamura"];

    for (var col in cols) {
      for (int i = 0; i <= 9; i++) {
        deck.add(AnimeCard(name: names[i % names.length], color: col, value: i.toString()));
      }
      deck.add(AnimeCard(name: "LEGENDARY", color: col, value: "∞", type: CardType.legendary));
    }
    deck.shuffle();
    return deck;
  }

  void _startTimer() {
    _turnTimer?.cancel();
    _secondsLeft = 15;
    _turnTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) setState(() => _secondsLeft > 0 ? _secondsLeft-- : _applyPenalty());
    });
  }

  void _applyPenalty() {
    setState(() {
      if (drawPile.isNotEmpty) myHand.add(drawPile.removeLast());
      isMyTurn = false;
    });
    _opponentTurn();
  }

  void _checkWin(String winner) {
    _turnTimer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF0D1B2A),
        title: Text(winner == "TU" ? "VITTORIA!" : "SCONFITTA...", style: TextStyle(color: winner == "TU" ? Colors.cyan : Colors.red)),
        content: Text("La battaglia è terminata.", style: const TextStyle(color: Colors.white)),
        actions: [TextButton(onPressed: () { Navigator.pop(c); _setupGame(); }, child: const Text("RIGIOCA"))],
      ),
    );
  }

  void playCard(int index) {
    if (!isMyTurn) return;
    AnimeCard selected = myHand[index];
    int currentVal = int.tryParse(lastPlayedCard!.value) ?? 0;
    int selectedVal = int.tryParse(selected.value) ?? 100;

    if (selected.type == CardType.legendary || selected.color == lastPlayedCard!.color || selectedVal >= currentVal) {
      _turnTimer?.cancel();
      setState(() {
        lastPlayedCard = selected;
        myHand.removeAt(index);
      });

      if (myHand.isEmpty) {
        if (!_ultimateShouted) {
          setState(() => myHand.addAll([drawPile.removeLast(), drawPile.removeLast()]));
          _passTurn();
        } else {
          _checkWin("TU");
        }
      } else {
        _passTurn();
      }
    }
  }

  void _passTurn() {
    setState(() => isMyTurn = false);
    _opponentTurn();
  }

  void _opponentTurn() async {
    await Future.delayed(const Duration(seconds: 2));
    int currentVal = int.tryParse(lastPlayedCard!.value) ?? 0;
    int pIdx = opponentHand.indexWhere((c) => c.type == CardType.legendary || c.color == lastPlayedCard!.color || (int.tryParse(c.value) ?? 100) >= currentVal);

    setState(() {
      if (pIdx != -1) {
        lastPlayedCard = opponentHand.removeAt(pIdx);
        if (opponentHand.isEmpty) { _checkWin("AVVERSARIO"); return; }
      } else {
        if (drawPile.isNotEmpty) opponentHand.add(drawPile.removeLast());
      }
      isMyTurn = true;
      _ultimateShouted = false;
      _startTimer();
    });
  }

  void _playUltimateAnimation() {
    setState(() => _ultimateShouted = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context));
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(widget.characterGifUrl, width: 300),
              const SizedBox(height: 20),
              Material(color: Colors.transparent, child: Text(widget.battleCry, style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold))),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(title: Text("TIMER: $_secondsLeft"), backgroundColor: Colors.transparent, elevation: 0),
      body: Column(
        children: [
          Text("AVVERSARIO: ${opponentHand.length}", style: const TextStyle(color: Colors.white70)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _cardUI(null, isDeck: true),
              const SizedBox(width: 20),
              if (lastPlayedCard != null) _cardUI(lastPlayedCard!),
            ],
          ),
          const Spacer(),
          if (isMyTurn && myHand.length <= 2)
            ElevatedButton(onPressed: _playUltimateAnimation, child: Text(widget.battleCry)),
          const SizedBox(height: 10),
          if (isMyTurn) ElevatedButton(onPressed: () { _turnTimer?.cancel(); _passTurn(); }, child: const Text("PASSA")),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: myHand.length,
              itemBuilder: (c, i) => GestureDetector(onTap: () => playCard(i), child: Padding(padding: const EdgeInsets.all(4), child: _cardUI(myHand[i]))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardUI(AnimeCard? card, {bool isDeck = false}) {
    bool isLeg = !isDeck && card?.type == CardType.legendary;
    return Container(
      width: 90,
      decoration: BoxDecoration(
        color: isDeck ? Colors.blueGrey.shade900 : card!.color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isLeg ? Colors.yellow : Colors.white),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(isDeck ? "MAZZO" : card!.value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          if (!isDeck) Text(card!.name, style: const TextStyle(color: Colors.white, fontSize: 8)),
        ],
      ),
    );
  }
} 