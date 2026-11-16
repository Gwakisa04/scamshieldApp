import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

class ScamApiClient {
  static const defaultBaseUrl = 'https://swahbert.qecure.online';

  final String baseUrl;

  ScamApiClient({String? baseUrl})
      : baseUrl = _trimSlash(baseUrl ?? defaultBaseUrl);

  static String _trimSlash(String url) =>
      url.endsWith('/') ? url.substring(0, url.length - 1) : url;

  Future<AnalysisResult> analyze(String message, String? phoneNumber) async {
    try {
      return await _analyzeOnce(message, phoneNumber);
    } catch (_) {
      // Render free tier sleeps: first request may 503/timeout. Retry once
      // after a short pause to let the server wake up.
      await Future<void>.delayed(const Duration(seconds: 3));
      return _analyzeOnce(message, phoneNumber);
    }
  }

  Future<AnalysisResult> _analyzeOnce(
      String message, String? phoneNumber) async {
    final body = <String, dynamic>{'message': message};
    final phone = phoneNumber?.trim();
    if (phone != null && phone.isNotEmpty && phone.toLowerCase() != 'null') {
      body['phoneNumber'] = phone;
    }

    final client = http.Client();
    try {
      final response = await client
          .post(
            Uri.parse('$baseUrl/api/v1/analyze'),
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 90));
      final raw = response.body;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw IOException('API ${response.statusCode}: $raw');
      }
      return AnalysisResult.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } finally {
      client.close();
    }
  }

  Future<ReportAck> reportNumber({
    required String phoneNumber,
    required int category,
    required String subtype,
    required String channel,
    String? messageSample,
  }) async {
    final client = http.Client();
    try {
      final response = await client
          .post(
            Uri.parse('$baseUrl/api/v1/report'),
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: jsonEncode({
              'phone_number': phoneNumber,
              'category': category,
              'subtype': subtype,
              'channel': channel,
              'message_sample': messageSample?.trim() ?? '',
            }),
          )
          .timeout(const Duration(seconds: 30));
      final raw = response.body;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw IOException('API ${response.statusCode}: $raw');
      }
      return ReportAck.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } finally {
      client.close();
    }
  }

  Future<List<String>> fetchReportedNumbers() async {
    final client = http.Client();
    try {
      final response = await client
          .get(
            Uri.parse('$baseUrl/api/v1/reports/sync?limit=10000'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return const [];
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['ok'] != true) return const [];
      return (data['numbers'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList();
    } catch (_) {
      return const [];
    } finally {
      client.close();
    }
  }
}

class ReportAck {
  final bool ok;
  final String phoneNumber;
  final int reportCount;
  final bool alreadyReported;

  ReportAck({
    required this.ok,
    required this.phoneNumber,
    required this.reportCount,
    required this.alreadyReported,
  });

  factory ReportAck.fromJson(Map<String, dynamic> json) => ReportAck(
        ok: json['ok'] == true,
        phoneNumber: (json['phone_number'] ?? '').toString(),
        reportCount: (json['report_count'] as num?)?.toInt() ?? 0,
        alreadyReported: json['already_reported'] == true,
      );
}

class IOException implements Exception {
  final String message;
  IOException(this.message);
  @override
  String toString() => message;
}
