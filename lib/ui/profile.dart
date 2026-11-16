import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/store.dart';
import '../core/theme.dart';
import '../core/lang.dart';
import '../services/platform.dart';
import 'risk_donut.dart';

class ProfileScreen extends StatelessWidget {
  final ThemeController controller;
  final VoidCallback onGoScan;
  final VoidCallback onGoHistory;
  final VoidCallback onRefresh;

  const ProfileScreen({
    super.key,
    required this.controller,
    required this.onGoScan,
    required this.onGoHistory,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final lang = LangScope.of(context).language;
    final t = (String key) => S.t(key, lang: lang);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final textColor = dark ? AppColors.darkText : AppColors.textSlate900;
    final subColor = dark ? AppColors.darkTextSecondary : AppColors.textSlate500;
    final cardColor = dark ? AppColors.darkCard : Colors.white;
    final store = AppStore.instance;

    final history = store.history;
    final scams = history.where((r) => r.isScam).length;
    final safe = history.length - scams;
    final saved = store.scamNumbers.length;
    final total = scams + safe;
    final score = total == 0 ? 0 : (100 * safe / total).round();

    return Scaffold(
      appBar: AppBar(
        title: Text(t('profile_title')),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.brandDark, AppColors.brand],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      child: const Icon(Icons.person_rounded,
                          color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t('profile_user_name'),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800)),
                          Text(t('profile_user_sub'),
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 12.5)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'â€¢ PROTECTION MEMBER',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _OverviewCard(
                t: t,
                dark: dark,
                textColor: textColor,
                subColor: subColor,
                cardColor: cardColor,
                scams: scams,
                safe: safe,
                saved: saved,
                score: score,
                total: total,
                lang: lang,
              ),
              const SizedBox(height: 16),
              Text(
                t('profile_actions'),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: subColor),
              ),
              const SizedBox(height: 8),
              _ActionRow(
                icon: Icons.search_rounded,
                title: t('profile_scan_title'),
                subtitle: t('profile_scan_sub'),
                dark: dark,
                textColor: textColor,
                subColor: subColor,
                cardColor: cardColor,
                onTap: onGoScan,
              ),
              _ActionRow(
                icon: Icons.history_rounded,
                title: t('profile_history_title'),
                subtitle: t('profile_history_sub'),
                dark: dark,
                textColor: textColor,
                subColor: subColor,
                cardColor: cardColor,
                onTap: onGoHistory,
              ),
              _ActionRow(
                icon: Icons.report_rounded,
                title: t('report_to_tcra'),
                subtitle: t('profile_report_sub'),
                dark: dark,
                textColor: textColor,
                subColor: subColor,
                cardColor: cardColor,
                onTap: onGoScan,
              ),
              const SizedBox(height: 18),
              Text(
                t('language_preferences'),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: subColor),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _LangButton(
                      label: t('english'),
                      selected: lang != 'sw',
                      dark: dark,
                      onTap: () {
                        controller.setLanguage('en');
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _LangButton(
                      label: t('kiswahili'),
                      selected: lang == 'sw',
                      dark: dark,
                      onTap: () {
                        controller.setLanguage('sw');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                t('general'),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: subColor),
              ),
              const SizedBox(height: 8),
              _ContactsRow(
                t: t,
                lang: lang,
                dark: dark,
                textColor: textColor,
                subColor: subColor,
                cardColor: cardColor,
                controller: controller,
                onReload: onRefresh,
              ),
              _SettingRow(
                icon: Icons.notifications_rounded,
                title: t('scam_alerts'),
                subtitle: t('scam_alerts_desc'),
                dark: dark,
                textColor: textColor,
                subColor: subColor,
                cardColor: cardColor,
                value: store.notificationsEnabled,
                onChanged: (v) async {
                  if (v && isAndroid) {
                    final granted =
                        await Permission.notification.request().isGranted;
                    if (!granted) {
                      v = false;
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(t('monitoring_needs_sms'))));
                      }
                    }
                  }
                  await store.setNotificationsEnabled(v);
                  if (context.mounted) {
                    (context as Element).markNeedsBuild();
                  }
                },
              ),
              _SettingRow(
                icon: Icons.dark_mode_rounded,
                title: t('dark_theme'),
                subtitle: t('dark_theme_desc'),
                dark: dark,
                textColor: textColor,
                subColor: subColor,
                cardColor: cardColor,
                value: dark,
                onChanged: (v) {
                  controller.setDark(v);
                },
              ),
              const SizedBox(height: 16),
              Text(
                t('blocked_scam_numbers'),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: subColor),
              ),
              const SizedBox(height: 8),
              if (store.scamNumbers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: dark ? AppColors.darkDivider : AppColors.divider),
                  ),
                  child: Text(
                    t('blocked_numbers_empty'),
                    style: TextStyle(fontSize: 13, color: subColor, height: 1.5),
                  ),
                )
              else
                ...store.scamNumbers.map((n) => _BlockedNumberRow(
                      number: n,
                      t: t,
                      lang: lang,
                      dark: dark,
                      textColor: textColor,
                      subColor: subColor,
                      cardColor: cardColor,
                      onRemove: () async {
                        await store.removeScamNumber(n.displayNumber);
                        onRefresh();
                      },
                    )),
              const SizedBox(height: 16),
              _ActionRow(
                icon: Icons.policy_rounded,
                title: t('privacy_policy'),
                subtitle: '',
                dark: dark,
                textColor: textColor,
                subColor: subColor,
                cardColor: cardColor,
                onTap: () => _showTextDialog(
                    context, t('privacy_policy'), t('privacy_policy_body')),
              ),
              _ActionRow(
                icon: Icons.description_rounded,
                title: t('terms_of_service'),
                subtitle: '',
                dark: dark,
                textColor: textColor,
                subColor: subColor,
                cardColor: cardColor,
                onTap: () => _showTextDialog(
                    context, t('terms_of_service'), t('terms_of_service_body')),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '${t('app_name')} Â· ${t('version')}',
                  style: TextStyle(fontSize: 12, color: subColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTextDialog(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(vertical: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: AlertDialog(
            title: Text(title),
            content: SizedBox(
              width: 300,
              child: SingleChildScrollView(child: Text(body)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.t('ok', lang: controller.language)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final dynamic t;
  final bool dark;
  final Color textColor;
  final Color subColor;
  final Color cardColor;
  final int scams;
  final int safe;
  final int saved;
  final int score;
  final int total;
  final String lang;

  const _OverviewCard({
    required this.t,
    required this.dark,
    required this.textColor,
    required this.subColor,
    required this.cardColor,
    required this.scams,
    required this.safe,
    required this.saved,
    required this.score,
    required this.total,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final caption = total == 0
        ? t('score_not_started')
        : score >= 80
            ? t('score_very_strong')
            : score >= 50
                ? t('score_strong')
                : t('score_at_risk');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: dark ? AppColors.darkDivider : AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('overview_title'),
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800, color: textColor),
          ),
          Text(t('overview_subtitle'),
              style: TextStyle(fontSize: 12.5, color: subColor)),
          const SizedBox(height: 14),
          Row(
            children: [
              RiskDonut(
                riskPercent: 0,
                safePercent: 0,
                scam: false,
                size: 110,
                score: score,
                caption: caption,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _Stat(
                        label: t('stat_scams'),
                        sub: t('stat_scams_sub'),
                        value: scams,
                        color: AppColors.red,
                        subColor: subColor,
                        textColor: textColor),
                    _Stat(
                        label: t('stat_safe'),
                        sub: t('stat_safe_sub'),
                        value: safe,
                        color: AppColors.green,
                        subColor: subColor,
                        textColor: textColor),
                    _Stat(
                        label: t('stat_saved'),
                        sub: t('stat_saved_sub'),
                        value: saved,
                        color: AppColors.brand,
                        subColor: subColor,
                        textColor: textColor),
                  ],
                ),
              ),
            ],
          ),
          if (total == 0) ...[
            const SizedBox(height: 10),
            Text(
              t('score_hint_no_scans'),
              style: TextStyle(fontSize: 12, color: subColor),
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String sub;
  final int value;
  final Color color;
  final Color subColor;
  final Color textColor;

  const _Stat({
    required this.label,
    required this.sub,
    required this.value,
    required this.color,
    required this.subColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$label (${sub.toLowerCase()})',
                    style: TextStyle(fontSize: 12.5, color: subColor)),
              ],
            ),
          ),
          Text('$value',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: textColor)),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool dark;
  final Color textColor;
  final Color subColor;
  final Color cardColor;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.dark,
    required this.textColor,
    required this.subColor,
    required this.cardColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: dark ? AppColors.darkDivider : AppColors.divider),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.brandSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.brand, size: 22),
        ),
        title: Text(title,
            style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: textColor)),
        subtitle: subtitle.isEmpty
            ? null
            : Text(subtitle,
                style: TextStyle(fontSize: 12, color: subColor)),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool dark;
  final Color textColor;
  final Color subColor;
  final Color cardColor;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.dark,
    required this.textColor,
    required this.subColor,
    required this.cardColor,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: dark ? AppColors.darkDivider : AppColors.divider),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.brandSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.brand, size: 22),
        ),
        title: Text(title,
            style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: textColor)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: subColor)),
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  final String label;
  final bool selected;
  final bool dark;
  final VoidCallback onTap;

  const _LangButton({
    required this.label,
    required this.selected,
    required this.dark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: selected ? AppColors.brand : (dark ? AppColors.darkSurface : AppColors.surfaceCard),
        foregroundColor: selected ? Colors.white : AppColors.brand,
        side: BorderSide(
            color: selected
                ? AppColors.brand
                : dark
                    ? AppColors.darkDivider
                    : AppColors.divider),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _BlockedNumberRow extends StatelessWidget {
  final dynamic number;
  final dynamic t;
  final String lang;
  final bool dark;
  final Color textColor;
  final Color subColor;
  final Color cardColor;
  final VoidCallback onRemove;

  const _BlockedNumberRow({
    required this.number,
    required this.t,
    required this.lang,
    required this.dark,
    required this.textColor,
    required this.subColor,
    required this.cardColor,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd MMM yyyy')
        .format(DateTime.fromMillisecondsSinceEpoch(number.addedAt));
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: dark ? AppColors.darkDivider : AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: dark ? AppColors.darkSurface : AppColors.lightRed,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.block_rounded, color: AppColors.red, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(number.displayNumber,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textColor)),
                Text(date, style: TextStyle(fontSize: 11.5, color: subColor)),
              ],
            ),
          ),
          TextButton(
            onPressed: onRemove,
            child: Text(
              t('remove'),
              style: const TextStyle(
                  color: AppColors.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactsRow extends StatelessWidget {
  final dynamic t;
  final String lang;
  final bool dark;
  final Color textColor;
  final Color subColor;
  final Color cardColor;
  final ThemeController controller;
  final VoidCallback onReload;

  const _ContactsRow({
    required this.t,
    required this.lang,
    required this.dark,
    required this.textColor,
    required this.subColor,
    required this.cardColor,
    required this.controller,
    required this.onReload,
  });

  Future<void> _request() async {
    if (isAndroid) {
      final status = await Permission.contacts.request();
      await AppStore.instance.setContactsAllowed(status.isGranted);
    } else {
      final allowed = AppStore.instance.contactsAllowed;
      await AppStore.instance.setContactsAllowed(!allowed);
    }
    onReload();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final allowed = store.contactsAllowed;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: dark ? AppColors.darkDivider : AppColors.divider),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.brandSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.contacts_rounded, color: AppColors.brand, size: 22),
        ),
        title: Text(t('contacts_access_title'),
            style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: textColor)),
        subtitle: Text(
          allowed ? t('contacts_access_allowed') : t('contacts_access_denied'),
          style: TextStyle(fontSize: 12, color: subColor),
        ),
        trailing: allowed
            ? null
            : TextButton(
                onPressed: _request,
                child: Text(t('allow'),
                    style: const TextStyle(
                        color: AppColors.brand,
                        fontWeight: FontWeight.w700)),
              ),
      ),
    );
  }
}
