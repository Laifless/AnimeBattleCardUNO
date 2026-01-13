import 'package:flutter/material.dart';
import 'game_table_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _codeController = TextEditingController();
  String selectedUniverse = "Bleach"; 

  final Map<String, String> battleCries = {
    "Bleach": "BANKAI!",
    "Jujutsu Kaisen": "ESPANSIONE DEL DOMINIO!",
    "Dragon Ball": "KAMEHAMEHA!",
    "One Piece": "GEAR... FIFTH!",
    "JoJo": "MUDA MUDA MUDA!",
  };

  final Map<String, String> characterGifs = {
    "Bleach": "https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExOHp1cTRhMW12aTNraTdlbm9yN3R4eTFiaWFqY2w0MW40YzF6cHl3OSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/2UIZzRk13t1m/giphy.gif",
    "Jujutsu Kaisen": "https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExaXFucTlnYm82cG9zYmFuc2c2Znp5ZHBkdDhrNjlxaW50ZXB5c3RhaXdkZmdhOSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/Lq0h920mP9Kz4F9L8B/giphy.gif",
    "Dragon Ball": "https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExMjUydWluNXh3OXB1cDNqNXVkajE3cGp4Z2h3eWd5Z2gydTNhaWc3czFzZGR2eCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/GRyrlV7c8P1gC/giphy.gif",
    "One Piece": "https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExbDV2bGJ4em1sNm1oNWgyd2M4a2Q3ZDM2dWx6a3pmMG9vc2g3c3U2ZyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/g0JP0ga1qGfOE/giphy.gif",
    "JoJo": "https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExbDN4MHN3d2VsbDZ6Z2lpdXk0NmQ2Mmx0Z3Z2aWdzcW9mdmFjYXNrbSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/Kglk07o07Y2s/giphy.gif",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.black, Colors.deepPurple.shade900], begin: Alignment.topCenter),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("ANIME BATTLE", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: TextField(
                controller: _codeController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Codice Stanza",
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedUniverse,
              dropdownColor: Colors.black,
              style: const TextStyle(color: Colors.cyanAccent, fontSize: 20),
              onChanged: (val) => setState(() => selectedUniverse = val!),
              items: battleCries.keys.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => GameTableScreen(
                roomId: _codeController.text.isEmpty ? "Solo" : _codeController.text,
                universe: selectedUniverse,
                battleCry: battleCries[selectedUniverse]!,
                characterGifUrl: characterGifs[selectedUniverse]!,
              ))),
              child: const Text("ENTRA IN BATTAGLIA"),
            )
          ],
        ),
      ),
    );
  }
}