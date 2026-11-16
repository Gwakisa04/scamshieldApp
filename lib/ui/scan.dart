import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/api_client.dart';
import '../core/models.dart';
import '../core/store.dart';
import '../core/theme.dart';
import '../core/lang.dart';
import 'risk_donut.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _messageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _client = ScamApiClient();

  bool _loading = false;
  AnalysisResult? _result;
  String _scannedMessage = '';
  String? _sender;

  @override
  void dispose() {
    _messageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final lang = LangScope.of(context).language;
    final t = (String key) => S.t(key, lang: lang);
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('enter_message_hint'))));
      return;
    }
    setState(() {
      _loading = true;
      _result = null;
      _scannedMessage = message;
      _sender =
          _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim();
    });

    try {
      final result = await _client.analyze(message, _sender);
      final scamRisk = result.scamPercentage / 100.0;
      await AppStore.instance.insertScan(ScanRecord(
        id: 0,
        message: message,
        label: result.label,
        confidence: scamRisk,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        phoneNumber: _sender,
      ));
      if (mounted) setState(() => _result = result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(t('api_error'))));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveSender() async {
    final lang = LangScope.of(context).language;
    final t = (String key) => S.t(key, lang: lang);
    if (_sender == null || _sender!.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t('no_sender_to_save'))));
      return;
    }
    await AppStore.instance.saveScamNumber(_sender!, 'Saved after scan');
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t('number_saved_scam'))));
    }
  }

  void _report() {
    final body = 'Scam Report: $_scannedMessage';
    Clipboard.setData(ClipboardData(text: body));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Report copied â€” send to TCRA 15040')));
  }

  @override
  Widget build(BuildContext context) {
    final lang = LangScope.of(context).language;
    final t = (String key) => S.t(key, lang: lang);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final textColor = dark ? AppColors.darkText : AppColors.textSlate900;
    final subColor = dark ? AppColors.darkTextSecondary : AppColors.textSlate500;
    final cardColor = dark ? AppColors.darkCard : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(_result == null ? t('manual_text_analysis') : t('scan_results')),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.brand))
              : _result == null
                  ? _buildInput(t, dark, textColor, subColor, cardColor)
                  : _buildResult(t, dark, textColor, subColor, cardColor),
        ),
      ),
    );
  }

  Widget _buildInput(dynamic t, bool dark, Color textColor, Color subColor, Color cardColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _RobotMascot(dark: dark),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                t('scan_description_input'),
                style: TextStyle(fontSize: 13.5, color: subColor, height: 1.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: dark ? AppColors.darkDivider : AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(dark ? 0.25 : 0.05),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: _messageController,
            maxLines: 6,
            style: TextStyle(
                color: dark ? AppColors.darkText : AppColors.inputText,
                fontSize: 14.5,
                height: 1.5),
            decoration: InputDecoration(
              hintText: t('scan_hint'),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: TextStyle(
              color: dark ? AppColors.darkText : AppColors.inputText, fontSize: 14.5),
          decoration: InputDecoration(
            labelText: t('sender_line').replaceFirst('%s', '').trim(),
            hintText: '+255...',
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: subColor,
                  side: BorderSide(
                      color: dark ? AppColors.darkDivider : AppColors.divider),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => _messageController.clear(),
                child: Text(t('clear')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _analyze,
                child: Text(
                  t('scan_content'),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResult(dynamic t, bool dark, Color textColor, Color subColor, Color cardColor) {
    final result = _result!;
    final isScam = result.isScam;
    final lang = LangScope.of(context).language;
    final verdict = lang == 'sw' ? result.verdictSw : result.verdictEn;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (verdict.isNotEmpty)
          Text(
            verdict,
            style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: isScam ? AppColors.red : AppColors.green),
          ),
        if (verdict.isNotEmpty) const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: dark ? AppColors.darkDivider : AppColors.divider),
          ),
          child: Column(
            children: [
              RiskDonut(
                riskPercent: result.scamPercentage,
                safePercent: result.legitimatePercentage,
                scam: isScam,
              ),
              const SizedBox(height: 12),
              Text(
                isScam ? t('scam_detected') : t('message_safe'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isScam ? AppColors.red : AppColors.green,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isScam ? t('scam_description') : t('safe_description'),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: subColor, height: 1.5),
              ),
              if (_sender != null && _sender!.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  S.senderLine(lang, _sender!),
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: subColor),
                ),
              ],
            ],
          ),
        ),
        if (result.analysisSummary.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: dark ? AppColors.darkDivider : AppColors.divider),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.assessment_outlined, size: 20, color: AppColors.brand),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    result.analysisSummary,
                    style: TextStyle(fontSize: 13.5, color: textColor, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (result.agentReply.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: dark ? AppColors.darkSurface : AppColors.brandSoft.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('agent_advice_title'),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.brand),
                ),
                const SizedBox(height: 6),
                Text(
                  result.agentReply,
                  style: TextStyle(fontSize: 13.5, color: textColor, height: 1.55),
                ),
              ],
            ),
          ),
        ],
        if (isScam) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: dark ? AppColors.darkSurface : AppColors.lightRed,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: dark ? AppColors.darkDivider : AppColors.borderRed),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('risk_indicators'),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.red),
                ),
                const SizedBox(height: 6),
                Text(
                  t('risk_points'),
                  style: TextStyle(fontSize: 12.5, color: subColor, height: 1.6),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          t('original_message'),
          style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: subColor),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: dark ? AppColors.darkSurface : AppColors.messageBoxBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: dark ? AppColors.darkDivider : AppColors.divider),
          ),
          child: Text(
            '" $_scannedMessage "',
            style: TextStyle(fontSize: 13.5, color: textColor, height: 1.55),
          ),
        ),
        const SizedBox(height: 18),
        if (isScam && _sender != null && _sender!.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.red,
                side: const BorderSide(color: AppColors.red),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.block_rounded, size: 20),
              label: Text(t('save_number_as_scam'),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              onPressed: _saveSender,
            ),
          ),
        if (isScam)
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brand,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.send_rounded, size: 20),
            label: Text(t('report_to_tcra'),
                style: const TextStyle(fontWeight: FontWeight.w700)),
            onPressed: _report,
          ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => _result = null),
          child: Text(
            t('clear'),
            style: TextStyle(color: subColor, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

/// Robot mascot badge at the top of the typing box. Uses the lying pose
/// (assets/images/robot_lay.png) when present, falling back to the peeking
/// pose. Rendered as a white circular "sticker" so it looks clean in both
/// light and dark themes regardless of the PNG background.
class _RobotMascot extends StatefulWidget {
  final bool dark;

  const _RobotMascot({required this.dark});

  @override
  State<_RobotMascot> createState() => _RobotMascotState();
}

class _RobotMascotState extends State<_RobotMascot> {
  late final Future<String> _asset = _pickAsset();

  static const _preferred = 'assets/images/robot_lay.png';
  static const _fallback = 'assets/images/robot_peek.png';

  Future<String> _pickAsset() async {
    for (final asset in [_preferred, _fallback]) {
      try {
        await rootBundle.load(asset);
        return asset;
      } catch (_) {
        continue;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: dark ? AppColors.darkDivider : AppColors.brandSoft,
          width: dark ? 2 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.35 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: FutureBuilder<String>(
          future: _asset,
          builder: (context, snap) {
            final asset = snap.data ?? '';
            if (asset.isEmpty) {
              return const Icon(Icons.smart_toy_rounded,
                  color: AppColors.brand, size: 30);
            }
            return Padding(
              padding: const EdgeInsets.all(7),
              child: Image.asset(
                asset,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.smart_toy_rounded,
                    color: AppColors.brand,
                    size: 30),
              ),
            );
          },
        ),
      ),
    );
  }
}
