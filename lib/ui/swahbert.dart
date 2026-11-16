import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../core/fraud_types.dart';
import '../core/lang.dart';
import '../core/models.dart';
import '../core/store.dart';
import '../core/theme.dart';

class SwahbertScreen extends StatefulWidget {
  const SwahbertScreen({super.key});

  @override
  State<SwahbertScreen> createState() => _SwahbertScreenState();
}

class _SwahbertScreenState extends State<SwahbertScreen> {
  final _numberController = TextEditingController();
  final _pageController = PageController(viewportFraction: 0.86);
  Timer? _ticker;

  bool _checking = false;
  String? _error;
  ScamNumber? _hit;

  /// De-duplicated, newest-first community scam reports.
  List<ScamNumber> get _reports {
    final seen = <String>{};
    final all = AppStore.instance.scamNumbers.toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return [
      for (final n in all)
        if (seen.add(n.normalizedNumber)) n
    ];
  }

  @override
  void initState() {
    super.initState();
    _startTicker();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pageController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  /// Auto-sliding "live updates" carousel of reported numbers.
  void _startTicker() {
    _ticker = Timer.periodic(const Duration(milliseconds: 3200), (_) {
      if (!_pageController.hasClients || !mounted) return;
      final total = _reports.length;
      if (total < 2) return;
      final current = _pageController.page ?? 0;
      final next = current >= total - 1 ? 0 : (current + 1).round();
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 650),
        curve: Curves.fastOutSlowIn,
      );
    });
  }

  /// Match by exact number or the last 9 digits, so +255712…, 0712… and
  /// 712… forms all resolve to the same report.
  ScamNumber? _lookup(String raw, List<ScamNumber> all) {
    String norm(String s) => s.replaceAll(RegExp(r'[\s\-().]'), '');
    final n = norm(raw);
    final tail = n.length > 9 ? n.substring(n.length - 9) : n;
    for (final s in all) {
      final sn = norm(s.normalizedNumber);
      if (sn == n) return s;
      final stail = sn.length > 9 ? sn.substring(sn.length - 9) : sn;
      if (tail == stail) return s;
    }
    return null;
  }

  FraudCategory? _categoryFor(String note) {
    for (final c in fraudCategories) {
      if (c.en == note || c.sw == note) return c;
    }
    return null;
  }

  Future<void> _check() async {
    FocusScope.of(context).unfocus();
    final t = (String key) => S.t(key, lang: LangScope.of(context).language);
    final raw = _numberController.text.trim();
    if (raw.replaceAll(RegExp(r'\D'), '').length < 7) {
      setState(() {
        _hit = null;
        _error = t('swahbert_invalid');
      });
      return;
    }
    setState(() {
      _error = null;
      _hit = null;
      _checking = true;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _checking = false;
      _hit = _lookup(raw, _reports);
    });
  }

  void _openDetail(BuildContext context, ScamNumber report) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _ReportDetailSheet(
        report: report,
        category: _categoryFor(report.note),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = LangScope.of(context).language;
    final t = (String key) => S.t(key, lang: lang);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = dark ? AppColors.darkCard : Colors.white;
    final textColor = dark ? AppColors.darkText : AppColors.textSlate900;
    final subColor = dark ? AppColors.darkTextSecondary : AppColors.textSlate500;
    final divider = dark ? AppColors.darkDivider : AppColors.divider;
    final reports = _reports;

    return Scaffold(
      backgroundColor: dark ? AppColors.darkBg : AppColors.bgApp,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        elevation: 0,
        title: Text(t('swahbert_title')),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                _hero(t, dark),
                const SizedBox(height: 20),
                _tickerSection(t, reports, dark, cardColor, divider),
                const SizedBox(height: 20),
                _checkCard(t, dark, cardColor, textColor, subColor, divider),
                const SizedBox(height: 14),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: _checking
                      ? _checkingCard(t, dark, cardColor, divider)
                      : _hit != null
                          ? _hitCard(t, _hit!, dark, lang, cardColor, divider)
                          : _error != null
                              ? _errorCard(t, dark, cardColor, divider)
                              : const SizedBox.shrink(),
                ),
                const SizedBox(height: 22),
                _recentSection(t, reports, dark, cardColor, textColor,
                    subColor, divider, lang),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _hero(dynamic t, bool dark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.brandDark, AppColors.brand, AppColors.brandBright],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: AppColors.brand, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  t('swahbert_hero'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            t('swahbert_subtitle'),
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _heroStat('${_reports.length}', t('swahbert_total')),
              const SizedBox(width: 10),
              _heroStat(
                  '${fraudCategories.length}', t('swahbert_types_tracked')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tickerSection(dynamic t, List<ScamNumber> reports, bool dark,
      Color cardColor, Color divider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _PulsingDot(),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                t('swahbert_live_label'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: dark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSlate500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          t('swahbert_live_sub'),
          style: TextStyle(
              fontSize: 11.5,
              color: dark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSlate500),
        ),
        const SizedBox(height: 12),
        if (reports.isEmpty)
          Container(
            height: 104,
            decoration: BoxDecoration(
              color: dark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: divider),
            ),
            child: Center(
              child: Text(
                t('swahbert_empty'),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12.5,
                    color: dark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSlate500),
              ),
            ),
          )
        else
          SizedBox(
            height: 118,
            child: PageView.builder(
              controller: _pageController,
              itemCount: reports.length,
              itemBuilder: (context, i) => _TickerCard(
                report: reports[i],
                category: _categoryFor(reports[i].note),
                onTap: () => _openDetail(context, reports[i]),
              ),
            ),
          ),
      ],
    );
  }

  Widget _checkCard(dynamic t, bool dark, Color cardColor, Color textColor,
      Color subColor, Color divider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.brandSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.phone_in_talk_rounded,
                    color: AppColors.brand, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t('swahbert_input_label'),
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: textColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _numberController,
            keyboardType: TextInputType.phone,
            onChanged: (_) => setState(() {}),
            style: TextStyle(
                color: dark ? AppColors.darkText : AppColors.inputText,
                fontSize: 15),
            decoration: InputDecoration(
              hintText: t('swahbert_input_hint'),
              prefixIcon:
                  Icon(Icons.dialpad_rounded, color: subColor, size: 20),
              suffixIcon: _numberController.text.isEmpty
                  ? IconButton(
                      tooltip: t('swahbert_paste'),
                      icon: Icon(Icons.content_paste_rounded,
                          color: subColor, size: 20),
                      onPressed: () async {
                        final data =
                            await Clipboard.getData(Clipboard.kTextPlain);
                        final text = data?.text?.trim();
                        if (text != null && text.isNotEmpty) {
                          _numberController.text = text;
                          setState(() {});
                        }
                      },
                    )
                  : IconButton(
                      tooltip: t('swahbert_clear'),
                      icon: Icon(Icons.close_rounded, color: subColor, size: 20),
                      onPressed: () {
                        _numberController.clear();
                        setState(() {
                          _hit = null;
                          _error = null;
                        });
                      },
                    ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brand,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _checking ? null : _check,
            child: _checking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : Text(t('swahbert_check'),
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _checkingCard(dynamic t, bool dark, Color cardColor, Color divider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: divider),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            t('swahbert_checking'),
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: dark ? AppColors.darkText : AppColors.textSlate900),
          ),
        ],
      ),
    );
  }

  Widget _errorCard(dynamic t, bool dark, Color cardColor, Color divider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkCard : AppColors.lightRed,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: dark ? AppColors.darkDivider : AppColors.borderRed),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.red, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(t('swahbert_invalid'),
                style: const TextStyle(fontSize: 13, color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  Widget _hitCard(dynamic t, ScamNumber hit, bool dark, String lang,
      Color cardColor, Color divider) {
    final category = _categoryFor(hit.note);
    final typeLabel = category != null
        ? (lang == 'sw' ? category.sw : category.en)
        : (hit.note.isEmpty ? t('swahbert_type_unknown') : hit.note);
    final date = DateFormat('dd MMM yyyy')
        .format(DateTime.fromMillisecondsSinceEpoch(hit.addedAt));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkCard : AppColors.lightRed,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: dark ? AppColors.darkDivider : AppColors.borderRed,
            width: 1.4),
        boxShadow: [
          BoxShadow(
            color: AppColors.red.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.gpp_bad_rounded,
                    color: AppColors.red, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t('swahbert_hit_title'),
                  style: const TextStyle(
                      color: AppColors.red,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hit.displayNumber,
            style: TextStyle(
              color: dark ? AppColors.darkText : AppColors.textSlate900,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.red.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(category?.icon ?? Icons.phishing_rounded,
                    color: AppColors.red, size: 15),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '${t('swahbert_type_label')}: $typeLabel',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.red,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${t('swahbert_reported_on')} $date',
            style: TextStyle(
                fontSize: 11.5,
                color: dark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSlate500),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: dark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_rounded,
                    color: AppColors.red, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t('swahbert_hit_body'),
                    style: TextStyle(
                        fontSize: 12.5,
                        height: 1.5,
                        color: dark
                            ? AppColors.darkText
                            : AppColors.textSlate900),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentSection(
      dynamic t,
      List<ScamNumber> reports,
      bool dark,
      Color cardColor,
      Color textColor,
      Color subColor,
      Color divider,
      String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('swahbert_recent_title'),
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: subColor),
        ),
        const SizedBox(height: 8),
        if (reports.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: divider),
            ),
            child: Text(
              t('swahbert_empty'),
              style: TextStyle(fontSize: 13, color: subColor, height: 1.5),
            ),
          )
        else
          ...reports.take(6).map((r) => _RecentReportTile(
                report: r,
                category: _categoryFor(r.note),
                lang: lang,
                dark: dark,
                cardColor: cardColor,
                textColor: textColor,
                subColor: subColor,
                divider: divider,
                onTap: () => _openDetail(context, r),
              )),
      ],
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.35, end: 1.0).animate(
        CurvedAnimation(parent: _c, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 9,
        height: 9,
        decoration: const BoxDecoration(
          color: AppColors.red,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _TickerCard extends StatelessWidget {
  final ScamNumber report;
  final FraudCategory? category;
  final VoidCallback? onTap;

  const _TickerCard({
    required this.report,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final lang = LangScope.of(context).language;
    final t = (String key) => S.t(key, lang: lang);
    final date = DateFormat('dd MMM')
        .format(DateTime.fromMillisecondsSinceEpoch(report.addedAt));
    final isNew =
        DateTime.now().millisecondsSinceEpoch - report.addedAt < 172800000;
    final c = category;
    final typeLabel = c != null
        ? (lang == 'sw' ? c.sw : c.en)
        : (report.note.isEmpty ? t('swahbert_type_unknown') : report.note);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: dark ? AppColors.darkDivider : AppColors.borderRed),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.3 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.red.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.block_rounded,
                color: AppColors.red, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        report.displayNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              dark ? AppColors.darkText : AppColors.textSlate900,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          t('swahbert_new_badge'),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(category?.icon ?? Icons.phishing_rounded,
                        color: AppColors.comfortOrange, size: 13),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        typeLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: dark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSlate500,
                        ),
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                          fontSize: 10.5,
                          color: dark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSlate500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

/// Small popup body shown when a reported number is tapped. Mirrors the
/// report form format: fraud type, specific trick, channel, message sample.
class _ReportDetailSheet extends StatelessWidget {
  final ScamNumber report;
  final FraudCategory? category;

  const _ReportDetailSheet({required this.report, required this.category});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final lang = LangScope.of(context).language;
    final t = (String key) => S.t(key, lang: lang);
    final c = category;
    final typeLabel = c != null
        ? (lang == 'sw' ? c.sw : c.en)
        : (report.note.isEmpty ? t('swahbert_type_unknown') : report.note);
    final subtype = (report.subtype == null || report.subtype!.isEmpty)
        ? t('swahbert_not_specified')
        : report.subtype!;
    final channel = report.channel == 'call'
        ? t('report_channel_call')
        : report.channel == 'sms'
            ? t('report_channel_sms')
            : t('swahbert_not_specified');
    final date = DateFormat('dd MMM yyyy')
        .format(DateTime.fromMillisecondsSinceEpoch(report.addedAt));
    final bg = dark ? AppColors.darkCard : Colors.white;
    final textColor = dark ? AppColors.darkText : AppColors.textSlate900;
    final subColor =
        dark ? AppColors.darkTextSecondary : AppColors.textSlate500;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: dark ? AppColors.darkDivider : AppColors.borderRed),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 30,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: subColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.red.withOpacity(0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.gpp_bad_rounded,
                      color: AppColors.red, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('swahbert_hit_title'),
                        style: const TextStyle(
                            color: AppColors.red,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8),
                      ),
                      Text(
                        report.displayNumber,
                        style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    t('scam_tag'),
                    style: const TextStyle(
                        color: AppColors.red,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _detailRow(
              t('report_category_label'),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(c?.icon ?? Icons.phishing_rounded,
                        color: AppColors.red, size: 15),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        typeLabel,
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: textColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            _detailRow(
              t('report_subtype_label'),
              Text(subtype,
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
            ),
            const SizedBox(height: 10),
            _detailRow(
              t('report_channel_label'),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    report.channel == 'call'
                        ? Icons.call_rounded
                        : Icons.sms_rounded,
                    size: 15,
                    color: subColor,
                  ),
                  const SizedBox(width: 6),
                  Text(channel,
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: textColor)),
                ],
              ),
            ),
            if (report.messageSample != null &&
                report.messageSample!.isNotEmpty) ...[
              const SizedBox(height: 10),
              _detailRow(
                t('report_paste_label'),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: dark ? AppColors.darkSurface : AppColors.messageBoxBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    report.messageSample!,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12, height: 1.45, color: subColor),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 13, color: subColor),
                const SizedBox(width: 5),
                Text(
                  '${t('swahbert_reported_on')} $date',
                  style: TextStyle(fontSize: 11.5, color: subColor),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: dark ? AppColors.darkSurface : AppColors.lightRed,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_rounded,
                      color: AppColors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t('swahbert_hit_body'),
                      style: TextStyle(
                          fontSize: 12.5,
                          height: 1.5,
                          color: textColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(t('ok'),
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, Widget value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: Colors.grey),
        ),
        const SizedBox(height: 4),
        value,
      ],
    );
  }
}

class _RecentReportTile extends StatelessWidget {
  final ScamNumber report;
  final FraudCategory? category;
  final String lang;
  final bool dark;
  final Color cardColor;
  final Color textColor;
  final Color subColor;
  final Color divider;
  final VoidCallback? onTap;

  const _RecentReportTile({
    required this.report,
    required this.category,
    required this.lang,
    required this.dark,
    required this.cardColor,
    required this.textColor,
    required this.subColor,
    required this.divider,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = (String key) => S.t(key, lang: lang);
    final date = DateFormat('dd MMM yyyy')
        .format(DateTime.fromMillisecondsSinceEpoch(report.addedAt));
    final c = category;
    final typeLabel = c != null
        ? (lang == 'sw' ? c.sw : c.en)
        : (report.note.isEmpty ? t('swahbert_type_unknown') : report.note);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(category?.icon ?? Icons.block_rounded,
                color: AppColors.red, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.displayNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: textColor),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        typeLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11.5, color: subColor),
                      ),
                    ),
                    Text(' • $date',
                        style: TextStyle(fontSize: 11.5, color: subColor)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.red.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              t('scam_tag'),
              style: const TextStyle(
                  color: AppColors.red,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
