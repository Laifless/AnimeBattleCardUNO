enum CardColor { rosso, blu, verde, giallo, speciale }

class AnimeCard {
  final String id;
  final CardColor color;
  final int? value; // 0-9
  final String? effect; // +2, salta, etc.

  AnimeCard({required this.id, required this.color, this.value, this.effect});

  // Per convertire la carta in un formato salvabile sul database
  Map<String, dynamic> toMap() => {
    'id': id,
    'color': color.index,
    'value': value,
    'effect': effect,
  };
}

class GameRoom {
  final String id; // Il codice "1001"
  final String password;
  final List<String> players;
  final String currentTurnId;
  final Map<String, dynamic> lastPlayedCard;

  GameRoom({
    required this.id, 
    required this.password, 
    this.players = const [], 
    this.currentTurnId = '',
    this.lastPlayedCard = const {},
  });
}