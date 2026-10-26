import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/tracks.dart';
import '../logic/setup_engine.dart';

class SavedSetup {
  final String id;
  final String name;
  final DateTime createdAt;
  final SessionParams session;
  final Map<String, double> values;

  SavedSetup(this.id, this.name, this.createdAt, this.session, this.values);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'session': session.toJson(),
        'values': values,
      };

  factory SavedSetup.fromJson(Map<String, dynamic> j) => SavedSetup(
        j['id'] as String,
        j['name'] as String,
        DateTime.parse(j['createdAt'] as String),
        SessionParams.fromJson(j['session'] as Map<String, dynamic>),
        (j['values'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
      );
}

class AppState extends ChangeNotifier {
  static const _prefsKey = 'saved_setups_v1';

  SessionParams session = SessionParams(track: kTracks.first);
  SetupResult? result;
  Map<String, double> values = {};
  List<SavedSetup> saved = [];
  int tab = 0;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        saved = (jsonDecode(raw) as List)
            .map((e) => SavedSetup.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      saved = [];
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(saved.map((s) => s.toJson()).toList()));
  }

  void setTab(int i) {
    tab = i;
    notifyListeners();
  }

  void touch() => notifyListeners();

  void setTrack(Track t) {
    session.track = t;
    session.downforceOverride = null;
    notifyListeners();
  }

  void calculate() {
    result = SetupEngine.calculate(session);
    values = Map.of(result!.values);
    notifyListeners();
  }

  void setValue(String key, double v) {
    values[key] = paramOf(key).snap(v);
    notifyListeners();
  }

  double get frontBalance => SetupEngine.balanceOf(values);

  Future<SavedSetup> saveCurrent(String name) async {
    final s = SavedSetup(
      DateTime.now().microsecondsSinceEpoch.toString(),
      name,
      DateTime.now(),
      session.copy(),
      Map.of(values),
    );
    saved.insert(0, s);
    notifyListeners();
    await _persist();
    return s;
  }

  Future<void> delete(String id) async {
    saved.removeWhere((s) => s.id == id);
    notifyListeners();
    await _persist();
  }

  void open(SavedSetup s) {
    session = s.session.copy();
    result = SetupEngine.calculate(session);
    values = Map.of(s.values);
    notifyListeners();
  }

  Future<void> clearAll() async {
    saved = [];
    notifyListeners();
    await _persist();
  }

  String exportText({Map<String, double>? v, SessionParams? s, String? title}) {
    final vals = v ?? values;
    final ses = s ?? session;
    final b = StringBuffer()
      ..writeln('BoxBox Academy — ${title ?? 'Setup'}')
      ..writeln('Tor: ${ses.track.name}')
      ..writeln('Sesja: ${ses.mode.label} | Styl: ${ses.style.label} | '
          '${ses.compound.label} | ${ses.trackTemp.round()}°C | '
          'deszcz ${ses.rainChance.round()}% | paliwo ${ses.fuelKg.round()} kg')
      ..writeln();
    for (final p in kParams) {
      b.writeln('${p.label}: ${p.format(vals[p.key]!)}');
    }
    return b.toString();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
