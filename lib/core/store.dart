import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class AppStore {
  static final AppStore instance = AppStore._();
  AppStore._();

  late SharedPreferences _prefs;

  static const _kHistory = 'scan_history';
  static const _kScamNumbers = 'scam_numbers';
  static const _kDarkTheme = 'dark_theme';
  static const _kLanguage = 'language';
  static const _kNotifications = 'notifications_enabled';
  static const _kMonitoring = 'sms_monitoring_enabled';
  static const _kOnboarding = 'onboarding_complete';
  static const _kContactsAllowed = 'contacts_allowed';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  List<ScanRecord> get history {
    final raw = _prefs.getStringList(_kHistory) ?? const [];
    return raw
        .map((e) => ScanRecord.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> insertScan(ScanRecord record) async {
    final all = history;
    final nextId = all.isEmpty ? 1 : all.map((r) => r.id).reduce((a, b) => a > b ? a : b) + 1;
    final updated = [
      ScanRecord(
        id: nextId,
        message: record.message,
        label: record.label,
        confidence: record.confidence,
        timestamp: record.timestamp,
        phoneNumber: record.phoneNumber,
      ),
      ...all,
    ];
    await _prefs.setStringList(
        _kHistory, updated.map((r) => jsonEncode(r.toJson())).toList());
  }

  List<ScamNumber> get scamNumbers {
    final raw = _prefs.getStringList(_kScamNumbers) ?? const [];
    return raw
        .map((e) => ScamNumber.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  ScamNumber? findScamNumber(String number) {
    final normalized = number.trim();
    for (final n in scamNumbers) {
      if (n.normalizedNumber == normalized ||
          n.displayNumber == normalized) {
        return n;
      }
    }
    return null;
  }

  Future<bool> saveScamNumber(
    String number,
    String note, {
    String? channel,
    String? subtype,
    String? messageSample,
  }) async {
    final all = scamNumbers;
    final normalized = number.trim();
    for (final n in all) {
      if (n.normalizedNumber == normalized) return false;
    }
    all.add(ScamNumber(
      id: all.isEmpty ? 1 : all.last.id + 1,
      normalizedNumber: normalized,
      displayNumber: normalized,
      addedAt: DateTime.now().millisecondsSinceEpoch,
      note: note,
      channel: channel,
      subtype: subtype,
      messageSample: messageSample,
    ));
    await _prefs.setStringList(
        _kScamNumbers, all.map((n) => jsonEncode(n.toJson())).toList());
    return true;
  }

  Future<void> removeScamNumber(String displayNumber) async {
    final all =
        scamNumbers.where((n) => n.displayNumber != displayNumber).toList();
    await _prefs.setStringList(
        _kScamNumbers, all.map((n) => jsonEncode(n.toJson())).toList());
  }

  Future<void> mergeReportedNumbers(List<String> numbers) async {
    if (numbers.isEmpty) return;
    final known = <String>{};
    for (final n in scamNumbers) {
      known.add(n.normalizedNumber);
    }
    var nextId = scamNumbers.isEmpty ? 0 : scamNumbers.map((n) => n.id).reduce(
          (a, b) => a > b ? a : b,
        );
    final additions = <ScamNumber>[];
    for (final raw in numbers) {
      final normalized = raw.trim();
      if (normalized.isEmpty || known.contains(normalized)) continue;
      known.add(normalized);
      nextId += 1;
      additions.add(ScamNumber(
        id: nextId,
        normalizedNumber: normalized,
        displayNumber: normalized,
        addedAt: DateTime.now().millisecondsSinceEpoch,
        note: 'Community reported',
      ));
    }
    if (additions.isEmpty) return;
    final all = [...scamNumbers, ...additions];
    await _prefs.setStringList(
        _kScamNumbers, all.map((n) => jsonEncode(n.toJson())).toList());
  }

  bool get darkTheme => _prefs.getBool(_kDarkTheme) ?? false;
  Future<void> setDarkTheme(bool value) => _prefs.setBool(_kDarkTheme, value);

  String get language => _prefs.getString(_kLanguage) ?? 'en';
  bool get isSwahili => language == 'sw';
  Future<void> setLanguage(String code) => _prefs.setString(_kLanguage, code);

  bool get notificationsEnabled => _prefs.getBool(_kNotifications) ?? true;
  Future<void> setNotificationsEnabled(bool value) =>
      _prefs.setBool(_kNotifications, value);

  bool get monitoringEnabled => _prefs.getBool(_kMonitoring) ?? false;
  Future<void> setMonitoringEnabled(bool value) =>
      _prefs.setBool(_kMonitoring, value);

  bool get onboardingComplete => _prefs.getBool(_kOnboarding) ?? false;
  Future<void> setOnboardingComplete(bool value) =>
      _prefs.setBool(_kOnboarding, value);

  bool get contactsAllowed => _prefs.getBool(_kContactsAllowed) ?? false;
  Future<void> setContactsAllowed(bool value) =>
      _prefs.setBool(_kContactsAllowed, value);
}
