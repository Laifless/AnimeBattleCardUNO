import 'package:flutter/material.dart';
import 'game_table_screen.dart';

// Modello per l'Eroe con il colore tematico
class AnimeHero {
  final String name;
  final String ultimateName;
  final String gifUrl;
  final Color themeColor; // Colore per l'interfaccia e l'Ultimate

  AnimeHero({
    required this.name, 
    required this.ultimateName, 
    required this.gifUrl, 
    this.themeColor = Colors.indigoAccent
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentStep = 0; 
  String selectedUniverse = "Jujutsu Kaisen";
  AnimeHero? selectedHero;

  // DATABASE ESPANSO DEGLI EROI
  final Map<String, List<AnimeHero>> universeHeroes = {
    "Bleach": [
      AnimeHero(name: "Ichigo Kurosaki", ultimateName: "BANKAI: TENSA ZANGETSU", gifUrl: "https://media.giphy.com/media/2UIZzRk13t1m/giphy.gif", themeColor: Colors.orange),
      AnimeHero(name: "Sosuke Aizen", ultimateName: "KYOKA SUIGETSU: IPNOSI", gifUrl: "https://media.giphy.com/media/DYB4inWOjppqE/giphy.gif", themeColor: Colors.deepPurple),
      AnimeHero(name: "Kenpachi Zaraki", ultimateName: "NOZARASHI: RILASCIO", gifUrl: "https://media.giphy.com/media/M9S0h_SAd8BSRGvT6C/giphy.gif", themeColor: Colors.red),
    ],
    "Jujutsu Kaisen": [
      AnimeHero(name: "Gojo Satoru", ultimateName: "DOMAIN EXPANSION: INFINITE VOID", gifUrl: "https://media.giphy.com/media/Lq0h920mP9Kz4F9L8B/giphy.gif", themeColor: Colors.deepPurpleAccent),
      AnimeHero(name: "Sukuna", ultimateName: "DOMAIN EXPANSION: MALEVOLENT SHRINE", gifUrl: "https://media.giphy.com/media/lszAB3hE5vwgz60A6E/giphy.gif", themeColor: Colors.redAccent),
      AnimeHero(name: "Yuji Itadori", ultimateName: "BLACK FLASH: SERIE", gifUrl: "https://media.giphy.com/media/v4C6S5S6f6S5S/giphy.gif", themeColor: Colors.pinkAccent),
      AnimeHero(name: "Megumi Fushiguro", ultimateName: "CHIMERA SHADOW GARDEN", gifUrl: "https://media.giphy.com/media/TdfyL9S2WvS5G/giphy.gif", themeColor: Colors.blueGrey),
    ],
    "One Piece": [
      AnimeHero(name: "Luffy Gear 5", ultimateName: "BAJRANG GUN: LIBERTÀ", gifUrl: "https://media.giphy.com/media/g0JP0ga1qGfOE/giphy.gif", themeColor: Colors.white70),
      AnimeHero(name: "Roronoa Zoro", ultimateName: "STILE A TRE SPADE: RE DELL'INFERNO", gifUrl: "https://media.giphy.com/media/4ExWdLKAn96D/giphy.gif", themeColor: Colors.greenAccent),
      AnimeHero(name: "Shanks", ultimateName: "HAKI DEL RE CONQUISTATORE", gifUrl: "https://media.giphy.com/media/12m3O9S6q2w/giphy.gif", themeColor: Colors.red),
    ],
    "Dragon Ball": [
      AnimeHero(name: "Goku UI", ultimateName: "ULTRA ISTINTO: KAMEHAMEHA", gifUrl: "https://media.giphy.com/media/GRyrlV7c8P1gC/giphy.gif", themeColor: Colors.lightBlueAccent),
      AnimeHero(name: "Vegeta Ultra Ego", ultimateName: "FINAL FLASH: DISTRUZIONE", gifUrl: "https://media.giphy.com/media/At8TemfXnodxu/giphy.gif", themeColor: Colors.purpleAccent),
      AnimeHero(name: "Broly", ultimateName: "GIGANTIC ROAR", gifUrl: "https://media.giphy.com/media/7VxvQXZYZeGqI/giphy.gif", themeColor: Colors.green),
    ],
    "JoJo": [
      AnimeHero(name: "Jotaro Kujo", ultimateName: "STAR PLATINUM: THE WORLD", gifUrl: "https://media.giphy.com/media/Kglk07o07Y2s/giphy.gif", themeColor: Colors.blue),
      AnimeHero(name: "Giorno Giovanna", ultimateName: "GOLD EXPERIENCE REQUIEM", gifUrl: "https://media.giphy.com/media/h79eMcg3MoBX2/giphy.gif", themeColor: Colors.yellowAccent),
      AnimeHero(name: "DIO Brando", ultimateName: "ROADO ROLLER DA!", gifUrl: "https://media.giphy.com/media/bUvBAZsNM6ZYI/giphy.gif", themeColor: Colors.amber),
    ],
    "God Tier": [
      AnimeHero(name: "Saitama", ultimateName: "SERIOUS PUNCH", gifUrl: "https://media.giphy.com/media/arbHBoiH3q20E/giphy.gif", themeColor: Colors.yellow),
      AnimeHero(name: "Rimuru Tempest", ultimateName: "BEELZEBUTH: PREDATORE", gifUrl: "https://media.giphy.com/media/Xv9nS72L7D3yM/giphy.gif", themeColor: Colors.cyan),
      AnimeHero(name: "Meliodas", ultimateName: "FULL COUNTER", gifUrl: "https://media.giphy.com/media/3o7TKvxnUf3ATBQwic/giphy.gif", themeColor: Colors.deepOrangeAccent),
      AnimeHero(name: "Mob Kageyama", ultimateName: "ESPLOSIONE: 100%", gifUrl: "https://media.giphy.com/media/10906XlF2UfXvq/giphy.gif", themeColor: Colors.pink),
    ]
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, selectedHero?.themeColor.withOpacity(0.3) ?? Colors.indigo.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter
          ),
        ),
        child: _buildUI(),
      ),
    );
  }

  Widget _buildUI() {
    switch (currentStep) {
      case 1: return _stepUniverse();
      case 2: return _stepPlayMenu();
      case 3: return _stepLobby();
      default: return _stepHome();
    }
  }

  Widget _stepHome() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text("ANIME BATTLE", style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 3)),
      const SizedBox(height: 60),
      _btn("GIOCA", () => setState(() => currentStep = 2)),
      _btn("MODIFICA EROE", () => setState(() => currentStep = 1), color: Colors.white12),
      if (selectedHero != null) 
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text("Eroe Attuale: ${selectedHero!.name}", style: TextStyle(color: selectedHero!.themeColor)),
        ),
    ]);
  }

  Widget _stepUniverse() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [
        const SizedBox(height: 60),
        const Text("SELEZIONA UNIVERSO", style: TextStyle(color: Colors.white70, fontSize: 18)),
        const SizedBox(height: 15),
        
        // Chips orizzontali per gli Universi
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: universeHeroes.keys.map((u) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(u),
              selected: selectedUniverse == u,
              onSelected: (val) => setState(() { selectedUniverse = u; selectedHero = null; }),
              selectedColor: Colors.cyanAccent.shade700,
            ),
          )).toList()),
        ),

        const SizedBox(height: 20),
        const Text("SCEGLI IL TUO EROE", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        // Lista Eroi
        Expanded(
          child: ListView.builder(
            itemCount: universeHeroes[selectedUniverse]!.length,
            itemBuilder: (context, index) {
              final hero = universeHeroes[selectedUniverse]![index];
              final isSelected = selectedHero == hero;
              return GestureDetector(
                onTap: () => setState(() => selectedHero = hero),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? hero.themeColor.withOpacity(0.4) : Colors.white10,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: isSelected ? hero.themeColor : Colors.transparent, width: 2),
                  ),
                  child: Row(children: [
                    Icon(Icons.flash_on, color: isSelected ? hero.themeColor : Colors.white24),
                    const SizedBox(width: 15),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(hero.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(hero.ultimateName, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    ]),
                    const Spacer(),
                    if (isSelected) const Icon(Icons.check_circle, color: Colors.white),
                  ]),
                ),
              );
            },
          ),
        ),

        _btn("CONFERMA", () => setState(() => currentStep = 0), color: Colors.green.shade800),
        const SizedBox(height: 30),
      ]),
    );
  }

  Widget _stepPlayMenu() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      _btn("CREATE ROOM", () => setState(() => currentStep = 3)),
      _btn("JOIN ROOM", () => _startGame(), color: Colors.white12),
      _btn("INDIETRO", () => setState(() => currentStep = 0), color: Colors.red.shade900),
    ]);
  }

  Widget _stepLobby() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text("LOBBY DI ATTESA", style: TextStyle(color: Colors.white, fontSize: 24)),
      const SizedBox(height: 20),
      _playerCard("TU (Host)", selectedHero?.name ?? "Scegli Eroe...", selectedHero?.themeColor ?? Colors.orange),
      const SizedBox(height: 10),
      _playerCard("AVVERSARIO", "In attesa...", Colors.blueGrey),
      const SizedBox(height: 40),
      _btn("AVVIA MATCH (BOT)", () => _startGame()),
      _btn("INDIETRO", () => setState(() => currentStep = 2), color: Colors.red.shade900),
    ]);
  }

  Widget _playerCard(String name, String sub, Color col) {
    return Container(
      width: 320, padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15), border: Border.all(color: col.withOpacity(0.5))),
      child: Row(children: [
        CircleAvatar(backgroundColor: col, child: const Icon(Icons.person, color: Colors.white)),
        const SizedBox(width: 15),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(sub, style: TextStyle(color: col.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold)),
        ])
      ]),
    );
  }

  Widget _btn(String txt, VoidCallback tap, {Color color = Colors.indigo}) {
    return Container(
      width: 250, margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.all(18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: tap, child: Text(txt, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _startGame() {
    if (selectedHero == null) {
      // Se non ha scelto nulla, impostiamo Gojo come default
      selectedHero = universeHeroes["Jujutsu Kaisen"]![0];
    }
    Navigator.push(context, MaterialPageRoute(builder: (c) => GameTableScreen(
      roomId: "ROOM_123", 
      universe: selectedUniverse,
      battleCry: selectedHero!.ultimateName,
      characterGifUrl: selectedHero!.gifUrl,
    )));
  }
}