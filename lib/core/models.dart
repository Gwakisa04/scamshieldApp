class AnalysisResult {
  final String label;
  final double confidence;
  final bool isScam;
  final int scamPercentage;
  final int legitimatePercentage;
  final String analysisSummary;
  final String notificationTitle;
  final String notificationBody;
  final String agentReply;
  final String verdictSw;
  final String verdictEn;
  final bool senderUnknown;

  AnalysisResult({
    required this.label,
    required this.confidence,
    required this.isScam,
    required this.scamPercentage,
    required this.legitimatePercentage,
    required this.analysisSummary,
    required this.notificationTitle,
    required this.notificationBody,
    required this.agentReply,
    required this.verdictSw,
    required this.verdictEn,
    required this.senderUnknown,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    final label = (json['label'] as String?) ?? 'Legitimate';
    final confidence = ((json['confidence'] as num?) ?? 0.0).toDouble();
    final isScam =
        (json['is_scam'] as bool?) ?? label.toLowerCase() == 'scam';
    final scamPct = (json['scam_percentage'] as num?)?.toInt() ??
        (isScam ? (confidence * 100).round() : 0);
    final legitPct = (json['legitimate_percentage'] as num?)?.toInt() ??
        (100 - scamPct);
    final summary = (json['analysis_summary'] as String?) ?? '';
    return AnalysisResult(
      label: label,
      confidence: confidence,
      isScam: isScam,
      scamPercentage: scamPct,
      legitimatePercentage: legitPct,
      analysisSummary: summary,
      notificationTitle:
          (json['notification_title'] as String?) ?? 'ScamShield',
      notificationBody:
          (json['notification_body'] as String?) ?? summary,
      agentReply: (json['agent_reply'] as String?) ?? '',
      verdictSw: (json['verdict_sw'] as String?) ?? '',
      verdictEn: (json['verdict_en'] as String?) ?? '',
      senderUnknown: (json['sender_unknown'] as bool?) ?? false,
    );
  }

  static AnalysisResult knownBlockedSender(String sender, String messagePreview) {
    var preview = messagePreview;
    if (preview.length > 80) preview = '${preview.substring(0, 80)}...';
    const agent =
        'Namba hii imeshahifadhi kwenye simu yako kama ulaghai. '
        'Usitume pesa, PIN, au msimbo. Thibitisha na mtoa huduma kwa namba rasmi.';
    return AnalysisResult(
      label: 'Scam',
      confidence: 1.0,
      isScam: true,
      scamPercentage: 100,
      legitimatePercentage: 0,
      analysisSummary: 'Known scam number — instant block',
      notificationTitle: 'ScamShield: Namba ya ulaghai!',
      notificationBody:
          'Mtumaji aliyehifadhi kama ulaghai: ${sender.isEmpty ? 'haijulikani' : sender}',
      agentReply: agent,
      verdictSw: 'Namba ya ulaghai iliyohifadhi',
      verdictEn: 'Saved scam number',
      senderUnknown: false,
    );
  }
}

class ScanRecord {
  final int id;
  final String message;
  final String label;
  final double confidence;
  final int timestamp;
  final String? phoneNumber;

  ScanRecord({
    required this.id,
    required this.message,
    required this.label,
    required this.confidence,
    required this.timestamp,
    required this.phoneNumber,
  });

  bool get isScam => label.toLowerCase() == 'scam';

  Map<String, dynamic> toJson() => {
        'id': id,
        'message': message,
        'label': label,
        'confidence': confidence,
        'timestamp': timestamp,
        'phoneNumber': phoneNumber,
      };

  factory ScanRecord.fromJson(Map<String, dynamic> json) => ScanRecord(
        id: (json['id'] as num).toInt(),
        message: (json['message'] as String?) ?? '',
        label: (json['label'] as String?) ?? 'Legitimate',
        confidence: ((json['confidence'] as num?) ?? 0.0).toDouble(),
        timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
        phoneNumber: json['phoneNumber'] as String?,
      );
}

class ScamNumber {
  final int id;
  final String normalizedNumber;
  final String displayNumber;
  final int addedAt;
  final String note;
  final String? channel;
  final String? subtype;
  final String? messageSample;

  ScamNumber({
    required this.id,
    required this.normalizedNumber,
    required this.displayNumber,
    required this.addedAt,
    required this.note,
    this.channel,
    this.subtype,
    this.messageSample,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'normalizedNumber': normalizedNumber,
        'displayNumber': displayNumber,
        'addedAt': addedAt,
        'note': note,
        'channel': channel,
        'subtype': subtype,
        'messageSample': messageSample,
      };

  factory ScamNumber.fromJson(Map<String, dynamic> json) => ScamNumber(
        id: (json['id'] as num).toInt(),
        normalizedNumber: (json['normalizedNumber'] as String?) ?? '',
        displayNumber: (json['displayNumber'] as String?) ?? '',
        addedAt: (json['addedAt'] as num?)?.toInt() ?? 0,
        note: (json['note'] as String?) ?? '',
        channel: json['channel'] as String?,
        subtype: json['subtype'] as String?,
        messageSample: json['messageSample'] as String?,
      );
}
