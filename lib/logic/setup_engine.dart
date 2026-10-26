import 'dart:math' as math;

import '../data/tracks.dart';

enum Compound { soft, medium, hard }

enum SessionMode { practice, qualifying, race }

enum DrivingStyle { aggressive, balanced, cautious }

extension CompoundX on Compound {
  String get label => const {
        Compound.soft: 'Soft',
        Compound.medium: 'Medium',
        Compound.hard: 'Hard',
      }[this]!;
}

extension SessionModeX on SessionMode {
  String get label => const {
        SessionMode.practice: 'Trening',
        SessionMode.qualifying: 'Kwalifikacje',
        SessionMode.race: 'Wyścig',
      }[this]!;
}

extension DrivingStyleX on DrivingStyle {
  String get label => const {
        DrivingStyle.aggressive: 'Agresywny',
        DrivingStyle.balanced: 'Zrównoważony',
        DrivingStyle.cautious: 'Ostrożny',
      }[this]!;

  String get tagline => const {
        DrivingStyle.aggressive: 'Ostre wejścia w zakręt i szybka reakcja',
        DrivingStyle.balanced: 'Stabilność i stałe tempo',
        DrivingStyle.cautious: 'Przewidywalny bolid i oszczędne opony',
      }[this]!;
}

/// Definicja jednego parametru setupu (zakres, krok, jednostka).
class Param {
  final String key;
  final String label;
  final String group; // aero | suspension | drivetrain | brakes
  final double min;
  final double max;
  final double step;
  final int decimals;
  final String unit;

  const Param(this.key, this.label, this.group, this.min, this.max, this.step,
      this.decimals, this.unit);

  double snap(double v) {
    final c = v.clamp(min, max).toDouble();
    final snapped = min + ((c - min) / step).round() * step;
    return double.parse(snapped.clamp(min, max).toStringAsFixed(decimals));
  }

  String format(double v) {
    final s = v.toStringAsFixed(decimals);
    return unit.isEmpty ? s : (unit == '%' || unit == '°' ? '$s$unit' : '$s $unit');
  }
}

/// Zakresy zgodne z menu setupu gry. Zmień tutaj, jeśli gra zmieni limity.
const List<Param> kParams = [
  Param('frontWing', 'Przednie skrzydło', 'aero', 0, 50, 1, 0, ''),
  Param('rearWing', 'Tylne skrzydło', 'aero', 0, 50, 1, 0, ''),
  Param('diffOn', 'Dyferencjał (on-throttle)', 'drivetrain', 10, 100, 1, 0, '%'),
  Param('diffOff', 'Dyferencjał (off-throttle)', 'drivetrain', 10, 100, 1, 0, '%'),
  Param('camberFront', 'Geometria kół (przód)', 'suspension', -3.5, -2.5, 0.1, 1, '°'),
  Param('camberRear', 'Geometria kół (tył)', 'suspension', -2.2, -0.7, 0.1, 1, '°'),
  Param('toeFront', 'Zbieżność (przód)', 'suspension', 0.0, 0.5, 0.01, 2, '°'),
  Param('toeRear', 'Zbieżność (tył)', 'suspension', 0.1, 0.5, 0.01, 2, '°'),
  Param('suspFront', 'Zawieszenie (przód)', 'suspension', 1, 11, 1, 0, ''),
  Param('suspRear', 'Zawieszenie (tył)', 'suspension', 1, 11, 1, 0, ''),
  Param('arbFront', 'Stabilizator (przód)', 'suspension', 1, 11, 1, 0, ''),
  Param('arbRear', 'Stabilizator (tył)', 'suspension', 1, 11, 1, 0, ''),
  Param('rideFront', 'Wysokość zawieszenia (przód)', 'suspension', 10, 40, 1, 0, 'mm'),
  Param('rideRear', 'Wysokość zawieszenia (tył)', 'suspension', 10, 40, 1, 0, 'mm'),
  Param('brakePressure', 'Ciśnienie hamulców', 'brakes', 80, 100, 1, 0, '%'),
  Param('brakeBias', 'Balans hamulców (przód)', 'brakes', 50, 70, 1, 0, '%'),
  Param('pressFront', 'Ciśnienie opon (przód)', 'brakes', 22.5, 29.5, 0.1, 1, 'psi'),
  Param('pressRear', 'Ciśnienie opon (tył)', 'brakes', 20.5, 26.5, 0.1, 1, 'psi'),
];

Param paramOf(String key) => kParams.firstWhere((p) => p.key == key);

class SessionParams {
  Track track;
  double trackTemp; // °C
  double rainChance; // %
  Compound compound;
  double fuelKg;
  SessionMode mode;
  DrivingStyle style;

  /// Typ toru nadpisany ręcznie: 0 niski, 1 średni, 2 wysoki. null = z toru.
  int? downforceOverride;

  SessionParams({
    required this.track,
    this.trackTemp = 32,
    this.rainChance = 0,
    this.compound = Compound.soft,
    this.fuelKg = 25,
    this.mode = SessionMode.qualifying,
    this.style = DrivingStyle.balanced,
    this.downforceOverride,
  });

  int get downforceClass =>
      downforceOverride ?? (track.downforce < 0.34 ? 0 : (track.downforce < 0.67 ? 1 : 2));

  double get downforceLevel => downforceOverride == null
      ? track.downforce
      : const [0.15, 0.5, 0.85][downforceOverride!];

  Map<String, dynamic> toJson() => {
        'track': track.id,
        'trackTemp': trackTemp,
        'rainChance': rainChance,
        'compound': compound.name,
        'fuelKg': fuelKg,
        'mode': mode.name,
        'style': style.name,
        'downforceOverride': downforceOverride,
      };

  factory SessionParams.fromJson(Map<String, dynamic> j) => SessionParams(
        track: trackById(j['track'] as String),
        trackTemp: (j['trackTemp'] as num).toDouble(),
        rainChance: (j['rainChance'] as num).toDouble(),
        compound: Compound.values.byName(j['compound'] as String),
        fuelKg: (j['fuelKg'] as num).toDouble(),
        mode: SessionMode.values.byName(j['mode'] as String),
        style: DrivingStyle.values.byName(j['style'] as String),
        downforceOverride: j['downforceOverride'] as int?,
      );

  SessionParams copy() => SessionParams.fromJson(toJson());
}

enum Level { low, medium, high }

extension LevelX on Level {
  String get label => const {
        Level.low: 'Niska',
        Level.medium: 'Średnia',
        Level.high: 'Wysoka',
      }[this]!;
}

class SetupResult {
  final Map<String, double> values;
  final Level performance;
  final Level stability;
  final Level tyreWear;
  final double frontBalance; // 0..100

  const SetupResult(this.values, this.performance, this.stability, this.tyreWear,
      this.frontBalance);

  double operator [](String key) => values[key]!;
}

/// Silnik obliczeń.
///
/// UWAGA: poniższe współczynniki to wartości WSTĘPNE (demonstracyjne). Docelowo
/// należy je zastąpić danymi/regułami BoxBox Academy.
class SetupEngine {
  static SetupResult calculate(SessionParams p) {
    final df = p.downforceLevel; // 0..1
    final rain = p.rainChance / 100;
    final hot = ((p.trackTemp - 30) / 20).clamp(-1.0, 1.0);
    final aggr = const {
      DrivingStyle.aggressive: 1.0,
      DrivingStyle.balanced: 0.0,
      DrivingStyle.cautious: -1.0,
    }[p.style]!;
    final race = p.mode == SessionMode.race;
    final quali = p.mode == SessionMode.qualifying;
    final fuelF = ((p.fuelKg - 5) / 105).clamp(0.0, 1.0);
    final compoundSoft = {
      Compound.soft: 1.0,
      Compound.medium: 0.5,
      Compound.hard: 0.0,
    }[p.compound]!;

    double wingBase = 5 + df * 35 + rain * 6 + (race ? 1 : 0);
    final fw = wingBase + aggr * 2 - (quali ? 1 : 0);
    final rw = wingBase + 2 - aggr * 2 + rain * 3;

    final diffOn = 80 - df * 28 - aggr * 8 + (race ? -3 : 0) - rain * 12;
    final diffOff = 55 - df * 15 + aggr * 6 - rain * 6;

    final camberFront = -3.0 - df * 0.2 - compoundSoft * 0.1 + (race ? 0.1 : 0) - hot * 0.05;
    final camberRear = -1.6 + df * 0.25 + (race ? 0.1 : 0);
    final toeFront = 0.06 + aggr * 0.04 + (race ? 0.02 : 0);
    final toeRear = 0.22 + (race ? 0.03 : 0) - aggr * 0.02;

    final suspBase = 4 + df * 4 - rain * 2 + aggr * 0.5;
    final suspFront = suspBase + 1;
    final suspRear = suspBase - 1;
    final arbFront = 6 + df * 2 + aggr - rain * 2;
    final arbRear = 4 + df * 1.5 - aggr * 0.5 - rain;

    final rideFront = 16 + (1 - df) * 4 + rain * 6 + (race ? 1 : 0);
    final rideRear = rideFront + 6 - df * 2;

    final brakePressure = 98 - rain * 8 - (race ? 2 : 0) + aggr * 1;
    final brakeBias = 56 - aggr * 1.5 + rain * 1 - (race ? 0.5 : 0) + fuelF * 0.5;

    final pressFront = 24.5 + hot * 0.8 - compoundSoft * 0.3 - rain * 1.5 + (race ? 0.2 : 0);
    final pressRear = 22.5 + hot * 0.6 - compoundSoft * 0.3 - rain * 1.2 + (race ? 0.2 : 0);

    final raw = <String, double>{
      'frontWing': fw,
      'rearWing': rw,
      'diffOn': diffOn,
      'diffOff': diffOff,
      'camberFront': camberFront,
      'camberRear': camberRear,
      'toeFront': toeFront,
      'toeRear': toeRear,
      'suspFront': suspFront,
      'suspRear': suspRear,
      'arbFront': arbFront,
      'arbRear': arbRear,
      'rideFront': rideFront,
      'rideRear': rideRear,
      'brakePressure': brakePressure,
      'brakeBias': brakeBias,
      'pressFront': pressFront,
      'pressRear': pressRear,
    };
    final values = {for (final e in raw.entries) e.key: paramOf(e.key).snap(e.value)};

    return SetupResult(
      values,
      _level(0.5 + aggr * 0.25 + (quali ? 0.15 : 0) - rain * 0.2),
      _level(0.55 - aggr * 0.25 + (race ? 0.1 : 0) + rain * 0.1),
      _level(0.5 + aggr * 0.2 + compoundSoft * 0.2 + hot * 0.15),
      balanceOf(values),
    );
  }

  /// Szacowany rozkład docisku przód/tył (%) na podstawie skrzydeł i balansu hamulców.
  static double balanceOf(Map<String, double> v) {
    final b = 50 + (v['frontWing']! - v['rearWing']!) * 0.25 + (v['brakeBias']! - 56) * 0.4 + 2;
    return b.clamp(40.0, 60.0);
  }

  static Level _level(double x) {
    final v = x.clamp(0.0, 1.0);
    final l = v < 0.34 ? Level.low : (v < 0.67 ? Level.medium : Level.high);
    return l;
  }

  static String archetype(SessionParams p) => p.style.label;

  static String archetypeDescription(SessionParams p) => const {
        DrivingStyle.aggressive: 'Szybka reakcja bolidu i większa rotacja w zakrętach.',
        DrivingStyle.balanced:
            'Uniwersalny setup zapewniający dobrą stabilność i konkurencyjne tempo.',
        DrivingStyle.cautious: 'Przewidywalny bolid, który oszczędza opony.',
      }[p.style]!;

  static double clampPct(double v) => math.max(0, math.min(100, v));
}
