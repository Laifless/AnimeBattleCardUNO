import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

// Usiamo le stesse classi definite in precedenza
enum CardType { normal, special, wild }
enum SpecialPower { none, skip, drawTwo, wildDrawFour, changeColor }

class AnimeCard {
  final String name; 
  Color color; 
  final String value;
  final CardType type; 
  final SpecialPower power;

  AnimeCard({required this.name, required this.color, required this.value, this.type = CardType.normal, this.power = SpecialPower.none});
}

class GameTableScreen extends StatefulWidget {
  final String roomId; 
  final String universe; 
  final String battleCry; // Contiene il nome della mossa (es. "BANKAI: TENSA...")
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
  int? _animatedCardIndex;

  @override
  void initState() { super.initState(); _setupGame(); }
  @override
  void dispose() { _turnTimer?.cancel(); super.dispose(); }

  void _setupGame() {
    drawPile = _generateDeck();
    setState(() {
      myHand = List.generate(7, (_) => drawPile.removeLast());
      opponentHand = List.generate(7, (_) => drawPile.removeLast());
      lastPlayedCard = drawPile.firstWhere((c) => c.type == CardType.normal);
      drawPile.remove(lastPlayedCard);
      _ultimateShouted = false;
      isMyTurn = true;
    });
    _startTimer();
  }

  // 1. MAZZO CON POTERI COLLEGATI AI PERSONAGGI
  List<AnimeCard> _generateDeck() {
    List<AnimeCard> deck = [];
    List<Color> cols = [Colors.red, Colors.blue, Colors.green, Colors.yellow];
    List<String> romComs = ["Hachiman", "Fuutarou", "Kazuya", "Nasa", "Ryuuji", "Takeo", "Nagatoro", "Marin"];

    for (var col in cols) {
      for (int i = 0; i <= 9; i++) {
        deck.add(AnimeCard(name: romComs[i % romComs.length], color: col, value: i.toString()));
      }
      // Speciali Shonen (Colorate)
      deck.add(AnimeCard(name: "Giorno G.", color: col, value: "Ø", type: CardType.special, power: SpecialPower.skip));
      deck.add(AnimeCard(name: "Luffy G5", color: col, value: "+2", type: CardType.special, power: SpecialPower.drawTwo));
    }

    // LEGGENDARIE (Nere) - 2 per tipo per non sbilanciare troppo
    for (int i = 0; i < 2; i++) {
      deck.add(AnimeCard(name: "Saitama", color: Colors.black, value: "+4", type: CardType.wild, power: SpecialPower.wildDrawFour));
      deck.add(AnimeCard(name: "Goku UI", color: Colors.black, value: "+4", type: CardType.wild, power: SpecialPower.wildDrawFour));
      deck.add(AnimeCard(name: "Gojo", color: Colors.black, value: "W", type: CardType.wild, power: SpecialPower.changeColor));
      deck.add(AnimeCard(name: "Rimuru", color: Colors.black, value: "W", type: CardType.wild, power: SpecialPower.changeColor));
    }

    deck.shuffle();
    return deck;
  }

  // Estrae la prima parola del grido di battaglia (es: "BANKAI" da "BANKAI: TENSA...")
  String _getUltimateButtonText() {
    if (widget.battleCry.contains(":")) {
      return widget.battleCry.split(":")[0];
    }
    return "ULTIMATE";
  }

  void playCard(int index) async {
    if (!isMyTurn || _animatedCardIndex != null) return;
    
    AnimeCard selected = myHand[index];
    bool canPlay = selected.color == Colors.black || 
                  selected.color == lastPlayedCard?.color || 
                  selected.value == lastPlayedCard?.value;

    if (canPlay) {
      setState(() => _animatedCardIndex = index);
      await Future.delayed(const Duration(milliseconds: 300));
      
      Color? newColor;
      if (selected.color == Colors.black) {
        newColor = await _showColorPicker(selected.name);
      }

      if (!mounted) return;

      _turnTimer?.cancel();
      setState(() {
        if (newColor != null) selected.color = newColor;
        lastPlayedCard = selected;
        myHand.removeAt(index);
        _animatedCardIndex = null;
        _applyPower(selected.power, false);
      });

      if (myHand.isEmpty) {
        _win(_ultimateShouted ? "VITTORIA TOTALE" : "VITTORIA (Senza Ultimate)");
      } else if (selected.power == SpecialPower.skip) {
        _startTimer(); // Salta il turno del bot, tocca ancora a te
      } else {
        _passTurn();
      }
    }
  }

  void _applyPower(SpecialPower p, bool isBot) {
    List<AnimeCard> targetHand = isBot ? myHand : opponentHand;
    int toDraw = (p == SpecialPower.drawTwo) ? 2 : (p == SpecialPower.wildDrawFour ? 4 : 0);
    for(int i=0; i<toDraw; i++) if(drawPile.isNotEmpty) targetHand.add(drawPile.removeLast());
  }

  void _passTurn() {
    setState(() => isMyTurn = false);
    _botTurn();
  }

  void _botTurn() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    int playIdx = opponentHand.indexWhere((c) =>
      c.color == Colors.black || c.color == lastPlayedCard?.color || c.value == lastPlayedCard?.value
    );

    setState(() {
      if (playIdx != -1) {
        AnimeCard botCard = opponentHand.removeAt(playIdx);
        if (botCard.color == Colors.black) {
          botCard.color = [Colors.red, Colors.blue, Colors.green, Colors.yellow][Random().nextInt(4)];
        }
        lastPlayedCard = botCard;
        _applyPower(botCard.power, true);
        if (opponentHand.isEmpty) { _win("AVVERSARIO"); return; }
        if (botCard.power == SpecialPower.skip) { _botTurn(); return; }
      } else {
        if (drawPile.isNotEmpty) opponentHand.add(drawPile.removeLast());
      }
      isMyTurn = true;
      _startTimer();
    });
  }

  // Dialog per il cambio colore leggendario
  Future<Color?> _showColorPicker(String name) async {
    return await showDialog<Color>(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1B263B),
        title: Text("$name scatena il potere!", style: const TextStyle(color: Colors.cyanAccent)),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [Colors.red, Colors.blue, Colors.green, Colors.yellow].map((col) => 
            GestureDetector(
              onTap: () => Navigator.pop(c, col),
              child: Container(width: 50, height: 50, decoration: BoxDecoration(color: col, shape: BoxShape.circle, border: Border.all(color: Colors.white))),
            )
          ).toList(),
        ),
      ),
    );
  }

  void _playUltimateAnimation() {
    setState(() => _ultimateShouted = true);
    showDialog(context: context, builder: (c) {
      Future.delayed(const Duration(seconds: 3), () => Navigator.pop(c));
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.battleCry, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
            const SizedBox(height: 20),
            Image.network(widget.characterGifUrl, width: 300),
          ],
        ),
      );
    });
  }

  void _startTimer() {
    _turnTimer?.cancel(); _secondsLeft = 15;
    _turnTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if(mounted) setState(() { if(_secondsLeft > 0) _secondsLeft--; else _passTurn(); });
    });
  }

  void _win(String w) {
    _turnTimer?.cancel();
    showDialog(context: context, barrierDismissible: false, builder: (c) => AlertDialog(
      title: const Text("MATCH FINISHED"),
      content: Text("Winner: $w"),
      actions: [ElevatedButton(onPressed: () { Navigator.pop(c); _setupGame(); }, child: const Text("REPLAY"))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Column(
          children: [
            Text("BOT: ${opponentHand.length} CARTE", style: const TextStyle(color: Colors.white54)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(onTap: () { if(isMyTurn) { myHand.add(drawPile.removeLast()); _passTurn(); } }, child: _card(null, isDeck: true)),
                const SizedBox(width: 30),
                _card(lastPlayedCard),
              ],
            ),
            const Spacer(),
            // IL TASTO ULTIMATE DINAMICO
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _ultimateShouted ? Colors.grey : Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                ),
                onPressed: _ultimateShouted ? null : _playUltimateAnimation, 
                child: Text(_ultimateShouted ? "USATA!" : _getUltimateButtonText().toUpperCase(), 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
              ),
            ),
            // MANO GIOCATORE
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: myHand.length,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemBuilder: (c, i) => GestureDetector(
                  onTap: () => playCard(i),
                  child: AnimatedScale(
                    scale: _animatedCardIndex == i ? 1.5 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    child: _card(myHand[i]),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _card(AnimeCard? c, {bool isDeck = false}) {
    return Container(
      width: 90, height: 130,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: isDeck ? Colors.indigo.shade900 : (c?.color ?? Colors.grey),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(isDeck ? "DECK" : (c?.value ?? ""), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          if (!isDeck && c != null) Text(c.name, style: const TextStyle(color: Colors.white70, fontSize: 9)),
        ],
      ),
    );
  }
}