class ScamPatterns {
  static final List<RegExp> patterns = [
    RegExp(r'tuma\s*hela', caseSensitive: false),
    RegExp(r'tuma\s*pesa', caseSensitive: false),
    RegExp(r'm[- ]?pesa', caseSensitive: false),
    RegExp(r'airtel\s*money', caseSensitive: false),
    RegExp(r'tigo\s*pesa', caseSensitive: false),
    RegExp(r'halipesi', caseSensitive: false),
    RegExp(r'kwa\s*wakala', caseSensitive: false),
    RegExp(r'pin\s*yako', caseSensitive: false),
    RegExp(r'otp|msimbo\s*wa\s*uthibitisho', caseSensitive: false),
    RegExp(r'hongera\s*umes(hinda|hindi)', caseSensitive: false),
    RegExp(r'umes(hinda|hindi)\s*(zawadi|shindana?)?', caseSensitive: false),
    RegExp(r'ushinde|umefuzu|zawadi\s*ya', caseSensitive: false),
    RegExp(r'bonus\s*ya\s*(kwanza|bei)', caseSensitive: false),
    RegExp(r'congratulations.*won', caseSensitive: false),
    RegExp(r'you\s*(have\s*)?won', caseSensitive: false),
    RegExp(r'claim\s*(your|the)\s*prize', caseSensitive: false),
    RegExp(r'gift\s*card', caseSensitive: false),
    RegExp(r'send\s*money', caseSensitive: false),
    RegExp(r'verify\s*your\s*account', caseSensitive: false),
    RegExp(r'account\s*(is\s*)?(blocked|suspended|frozen)', caseSensitive: false),
    RegExp(r'urgent.{0,20}(action|response)', caseSensitive: false),
    RegExp(r'click\s*(this|the)\s*link', caseSensitive: false),
    RegExp(r'bit\.ly|tinyurl|t\.co/', caseSensitive: false),
    RegExp(r'\+?\d{1,3}[\s-]?\d{3}[\s-]?\d{3,6}\s*wa\w*\s* Elias?', caseSensitive: false),
    RegExp(r'login.{0,15}(password|credential)', caseSensitive: false),
  ];

  /// Returns how many suspicious patterns the message matches.
  static int score(String message) {
    if (message.isEmpty) return 0;
    var count = 0;
    for (final p in patterns) {
      if (p.hasMatch(message)) count++;
    }
    return count;
  }

  static bool isSuspicious(String message, {int threshold = 1}) =>
      score(message) >= threshold;
}
