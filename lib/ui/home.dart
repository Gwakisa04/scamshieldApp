import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

import '../core/api_client.dart';
import '../core/fraud_types.dart';
import '../core/models.dart';
import '../core/store.dart';
import '../core/theme.dart';
import '../core/lang.dart';
import '../services/platform.dart';
import 'report.dart';
import 'swahbert.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onGoScan;
  final VoidCallback onGoProfile;
  final VoidCallback onGoHistory;
  final bool active;

  const HomeScreen({
    super.key,
    required this.onGoScan,
    required this.onGoProfile,
    required this.onGoHistory,
    this.active = true,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _monitoring = AppStore.instance.monitoringEnabled;
  VideoPlayerController? _video;

  static const _robotVideoUrl =
      'https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20260508_215831_c6a8989c-d716-4d8d-8745-e972a2eec711.mp4';

  @override
  void initState() {
    super.initState();
    _initVideo();
    _syncReportedNumbers();
  }

  /// Pull community-flagged numbers once and merge them into the local
  /// scam list, so the native guard can alert on them instantly.
  Future<void> _syncReportedNumbers() async {
    final numbers = await ScamApiClient().fetchReportedNumbers();
    if (numbers.isNotEmpty) {
      await AppStore.instance.mergeReportedNumbers(numbers);
    }
  }

  Future<void> _initVideo() async {
    try {
      final controller =
          VideoPlayerController.networkUrl(Uri.parse(_robotVideoUrl));
      await controller.initialize();
      controller.setLooping(true);
      controller.setVolume(0);
      await controller.play();
      if (mounted) setState(() => _video = controller);
    } catch (_) {
      if (mounted) setState(() => _video = null);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _monitoring = AppStore.instance.monitoringEnabled;
  }

  @override
  void didUpdateWidget(HomeScreen old) {
    super.didUpdateWidget(old);
    if (old.active != widget.active && _video != null) {
      widget.active ? _video!.play() : _video!.pause();
    }
  }

  @override
  void dispose() {
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = LangScope.of(context).t;
    final store = AppStore.instance;
    final scans = store.history.take(6).toList();
    final video = _video;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (video != null && video.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: video.value.size.width,
                height: video.value.size.height,
                child: VideoPlayer(video),
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.darkBg.withOpacity(0.82),
                    AppColors.darkBg.withOpacity(0.94),
                    AppColors.darkBg.withOpacity(0.99),
                  ],
                ),
              ),
            ),
          ),
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 0, 100),
                children: [
                  _header(t),
                const SizedBox(height: 16),
                _statusCard(t),
                const SizedBox(height: 22),
                _sectionHeader(
                    t('recent_scans'), t('view_all'), widget.onGoHistory),
                const SizedBox(height: 12),
                _recentScans(scans, t),
                const SizedBox(height: 22),
                _sectionHeader(t('services'), null, null),
                const SizedBox(height: 12),
                _services(t),
                const SizedBox(height: 22),
                _LiveTicker(
                  onTap: () => _openSwahbert(context),
                ),
                const SizedBox(height: 22),
                _sectionHeader(t('how_it_works'), null, null),
                const SizedBox(height: 12),
                _steps(t),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(dynamic t) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.brand,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.shield_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('app_name'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  t('profile_user_sub'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          _CircleIcon(
            icon: Icons.person_rounded,
            onTap: widget.onGoProfile,
          ),
        ],
      ),
    );
  }

  Widget _statusCard(dynamic t) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.darkDivider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _monitoring
                    ? AppColors.green.withOpacity(0.15)
                    : AppColors.comfortOrange.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _monitoring
                    ? Icons.verified_user_rounded
                    : Icons.security_rounded,
                color: _monitoring ? AppColors.green : AppColors.comfortOrange,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _monitoring ? t('protection_active') : t('protection_ready'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Switch(
              value: _monitoring,
              activeColor: AppColors.green,
              onChanged: (v) async {
                if (v && isAndroid) {
                  final sms = await Permission.sms.request();
                  if (!sms.isGranted) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(t('monitoring_needs_sms'))));
                    }
                    return;
                  }
                  await Permission.phone.request();
                  await Permission.notification.request();
                }
                await AppStore.instance.setMonitoringEnabled(v);
                setState(() => _monitoring = v);
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _sectionHeader(String title, String? action, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (action != null)
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(40, 32),
              ),
              child: Text(
                action,
                style: const TextStyle(
                  color: AppColors.comfortOrange,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _recentScans(List<ScanRecord> scans, dynamic t) {
    if (scans.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.darkDivider),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.manage_search_rounded,
                    color: AppColors.comfortOrange, size: 30),
                const SizedBox(height: 8),
                Text(
                  t('no_scans_yet'),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700),
                ),
                Text(
                  t('no_scans_sub'),
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.45), fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 236,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 20),
        itemCount: scans.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _ScanCard(
          record: scans[i],
          onTap: widget.onGoHistory,
        ),
      ),
    );
  }

  void _openReport(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ReportScreen()),
    );
  }

  void _openSwahbert(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SwahbertScreen()),
    );
  }

  Widget _services(dynamic t) {
    final items = [
      _Service(
        icon: Icons.manage_search_rounded,
        color: AppColors.comfortOrange,
        title: t('svc_scan_title'),
        sub: t('svc_scan_sub'),
        onTap: widget.onGoScan,
      ),
      _Service(
        icon: Icons.auto_awesome_rounded,
        color: AppColors.brandBright,
        title: t('svc_ai_title'),
        sub: t('svc_ai_sub'),
        onTap: () => _openSwahbert(context),
      ),
      _Service(
        icon: Icons.block_rounded,
        color: AppColors.red,
        title: t('svc_block_title'),
        sub: t('svc_block_sub'),
        onTap: widget.onGoProfile,
      ),
      _Service(
        icon: Icons.report_rounded,
        color: AppColors.green,
        title: t('svc_report_title'),
        sub: t('svc_report_sub'),
        onTap: () => _openReport(context),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.45,
        children: items,
      ),
    );
  }

  Widget _steps(dynamic t) {
    final steps = [
      (t('home_step1_title'), t('home_step1_desc'), t('home_step1_more')),
      (t('home_step2_title'), t('home_step2_desc'), t('home_step2_more')),
      (t('home_step3_title'), t('home_step3_desc'), t('home_step3_more')),
    ];

    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++)
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _showStepDialog(context, i, steps[i].$1, steps[i].$3),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.darkDivider),
                ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.comfortOrange,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: AppColors.brandDeep,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps[i].$1.replaceFirst(RegExp(r'^\d+\.\s*'), ''),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          steps[i].$2,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 11.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.comfortOrange, size: 22),
                ],
              ),
            ),
            ),
        ],
      ),
    );
  }

  void _showStepDialog(
      BuildContext context, int step, String title, String more) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.darkDivider),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.45),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.comfortOrange,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${step + 1}',
                            style: const TextStyle(
                              color: AppColors.brandDeep,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            title.replaceFirst(RegExp(r'^\d+\.\s*'), ''),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      more,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13.5,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.comfortOrange,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('OK',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkDivider),
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
      ),
    );
  }
}

class _ScanCard extends StatelessWidget {
  final ScanRecord record;
  final VoidCallback onTap;

  const _ScanCard({required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isScam = record.isScam;
    final accent = isScam ? AppColors.red : AppColors.green;
    final sender = record.phoneNumber ?? 'Unknown';

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.darkDivider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                height: 88,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isScam ? Icons.gpp_bad_rounded : Icons.verified_user_rounded,
                  color: accent,
                  size: 38,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sender,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.bolt_rounded, size: 12, color: accent),
                      const SizedBox(width: 4),
                      Text(
                        isScam ? 'SCAM' : 'SAFE',
                        style: TextStyle(
                          color: accent,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 10, 10),
              child: Row(
                children: [
                  Text(
                    '${(record.confidence * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward_rounded,
                        color: AppColors.brandDeep, size: 16),
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

class _Service extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String sub;
  final VoidCallback onTap;

  const _Service({
    required this.icon,
    required this.color,
    required this.title,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.darkDivider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Home banner: robot mascot + auto-sliding live community scam reports.
/// Tapping it opens the SwahBERT number-check page.
class _LiveTicker extends StatefulWidget {
  final VoidCallback onTap;

  const _LiveTicker({required this.onTap});

  @override
  State<_LiveTicker> createState() => _LiveTickerState();
}

class _LiveTickerState extends State<_LiveTicker> {
  Timer? _timer;
  int _index = 0;
  List<ScamNumber> _reports = const [];

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(milliseconds: 3000), (_) {
      if (!mounted || _reports.length < 2) return;
      setState(() => _index = (_index + 1) % _reports.length);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refresh();
    if (_index >= _reports.length) _index = 0;
  }

  void _refresh() {
    final seen = <String>{};
    final all = AppStore.instance.scamNumbers.toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    _reports = [
      for (final n in all)
        if (seen.add(n.normalizedNumber)) n
    ];
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = LangScope.of(context).t;
    final reports = _reports;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.darkDivider),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/images/robot_peek.png',
              height: 82,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      _PulseDot(),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          t('swahbert_live_label'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.darkTextSecondary,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 46,
                    child: reports.isEmpty
                        ? Text(
                            t('swahbert_empty'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 11.5,
                              height: 1.35,
                            ),
                          )
                        : AnimatedSwitcher(
                            duration: const Duration(milliseconds: 480),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, anim) =>
                                FadeTransition(
                              opacity: anim,
                              child: SlideTransition(
                                position: anim.drive(Tween(
                                  begin: const Offset(0, 0.7),
                                  end: Offset.zero,
                                )),
                                child: child,
                              ),
                            ),
                            child: _LiveTickerRow(
                              key: ValueKey(_index),
                              report: reports[_index],
                            ),
                          ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        t('swahbert_tap_check'),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 10.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded,
                          color: AppColors.comfortOrange, size: 13),
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

class _LiveTickerRow extends StatelessWidget {
  final ScamNumber report;

  const _LiveTickerRow({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final lang = LangScope.of(context).language;
    FraudCategory? c;
    for (final x in fraudCategories) {
      if (x.en == report.note || x.sw == report.note) {
        c = x;
        break;
      }
    }
    final typeLabel = c != null
        ? (lang == 'sw' ? c.sw : c.en)
        : (report.note.isEmpty ? S.t('swahbert_type_unknown', lang: lang) : report.note);
    final icon = c?.icon ?? Icons.phishing_rounded;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.red.withOpacity(0.14),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.block_rounded,
              color: AppColors.red, size: 19),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                report.displayNumber,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(icon, color: AppColors.comfortOrange, size: 12),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      typeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.red.withOpacity(0.14),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'SCAM',
            style: TextStyle(
              color: AppColors.red,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ],
    );
  }
}


class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
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
      opacity: Tween(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _c, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.red,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
