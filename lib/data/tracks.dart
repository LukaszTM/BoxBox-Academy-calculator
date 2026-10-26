enum Direction { clockwise, counterClockwise }

class Track {
  final String id;
  final String name;
  final String country;
  final double lengthKm;
  final int turns;
  final Direction direction;

  /// 0.0 = tor niskiego docisku (np. Monza), 1.0 = tor wysokiego docisku (np. Monako).
  final double downforce;

  const Track(this.id, this.name, this.country, this.lengthKm, this.turns,
      this.direction, this.downforce);

  String get directionLabel =>
      direction == Direction.clockwise ? 'Prawoskrętny' : 'Lewoskrętny';

  String get downforceLabel => downforce < 0.34
      ? 'Niski docisk'
      : downforce < 0.67
          ? 'Średni docisk'
          : 'Wysoki docisk';
}

const kCW = Direction.clockwise;
const kCCW = Direction.counterClockwise;

const List<Track> kTracks = [
  Track('bahrain', 'Bahrain International Circuit', 'Bahrajn', 5.412, 15, kCW, 0.5),
  Track('jeddah', 'Jeddah Corniche Circuit', 'Arabia Saudyjska', 6.174, 27, kCCW, 0.25),
  Track('melbourne', 'Albert Park Circuit', 'Australia', 5.278, 14, kCCW, 0.45),
  Track('suzuka', 'Suzuka International Racing Course', 'Japonia', 5.807, 18, kCW, 0.7),
  Track('shanghai', 'Shanghai International Circuit', 'Chiny', 5.451, 16, kCW, 0.5),
  Track('miami', 'Miami International Autodrome', 'USA', 5.412, 19, kCCW, 0.45),
  Track('imola', 'Autodromo Enzo e Dino Ferrari', 'Włochy', 4.909, 19, kCCW, 0.7),
  Track('monaco', 'Circuit de Monaco', 'Monako', 3.337, 19, kCW, 1.0),
  Track('barcelona', 'Circuit de Barcelona-Catalunya', 'Hiszpania', 4.657, 14, kCW, 0.75),
  Track('montreal', 'Circuit Gilles Villeneuve', 'Kanada', 4.361, 14, kCW, 0.25),
  Track('spielberg', 'Red Bull Ring', 'Austria', 4.318, 10, kCW, 0.3),
  Track('silverstone', 'Silverstone Circuit', 'Wielka Brytania', 5.891, 18, kCW, 0.55),
  Track('spa', 'Circuit de Spa-Francorchamps', 'Belgia', 7.004, 19, kCW, 0.25),
  Track('hungaroring', 'Hungaroring', 'Węgry', 4.381, 14, kCW, 0.9),
  Track('zandvoort', 'Circuit Zandvoort', 'Holandia', 4.259, 14, kCW, 0.85),
  Track('monza', 'Autodromo Nazionale Monza', 'Włochy', 5.793, 11, kCW, 0.0),
  Track('baku', 'Baku City Circuit', 'Azerbejdżan', 6.003, 20, kCCW, 0.2),
  Track('singapore', 'Marina Bay Street Circuit', 'Singapur', 4.940, 19, kCCW, 0.85),
  Track('austin', 'Circuit of the Americas', 'USA', 5.513, 20, kCCW, 0.55),
  Track('mexico', 'Autódromo Hermanos Rodríguez', 'Meksyk', 4.304, 17, kCW, 0.8),
  Track('interlagos', 'Autódromo José Carlos Pace', 'Brazylia', 4.309, 15, kCCW, 0.5),
  Track('lasvegas', 'Las Vegas Strip Circuit', 'USA', 6.201, 17, kCCW, 0.15),
  Track('lusail', 'Lusail International Circuit', 'Katar', 5.419, 16, kCW, 0.6),
  Track('yasmarina', 'Yas Marina Circuit', 'Abu Zabi', 5.281, 16, kCW, 0.5),
];

Track trackById(String id) =>
    kTracks.firstWhere((t) => t.id == id, orElse: () => kTracks.first);
