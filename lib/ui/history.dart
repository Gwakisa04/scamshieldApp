import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/models.dart';
import '../core/store.dart';
import '../core/theme.dart';
import '../core/lang.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _tab = 0;
  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final lang = LangScope.of(context).language;
    final t = (String key) => S.t(key, lang: lang);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final textColor = dark ? AppColors.darkText : AppColors.textSlate900;
    final subColor = dark ? AppColors.darkTextSecondary : AppColors.textSlate500;
    final cardColor = dark ? AppColors.darkCard : Colors.white;

    final all = AppStore.instance.history;
    final records = _tab == 0
        ? all
        : all.where((r) => _tab == 1 ? r.isScam : !r.isScam).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(t('nav_history')),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    _FilterChip(
                      label: t('all'),
                      selected: _tab == 0,
                      dark: dark,
                      onTap: () => setState(() => _tab = 0),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: t('scams'),
                      selected: _tab == 1,
                      dark: dark,
                      onTap: () => setState(() => _tab = 1),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: t('legitimate'),
                      selected: _tab == 2,
                      dark: dark,
                      onTap: () => setState(() => _tab = 2),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: records.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.history_rounded,
                                size: 48,
                                color:
                                    dark ? AppColors.darkDivider : AppColors.divider),
                            const SizedBox(height: 10),
                            Text(
                              t('end_of_history'),
                              style:
                                  TextStyle(fontSize: 13, color: subColor),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: records.length,
                        itemBuilder: (context, i) =>
                            _HistoryTile(
                          record: records[i],
                          expanded: _expanded.contains(records[i].id),
                          t: t,
                          lang: lang,
                          dark: dark,
                          textColor: textColor,
                          subColor: subColor,
                          cardColor: cardColor,
                          onToggle: () => setState(() {
                            final id = records[i].id;
                            if (_expanded.contains(id)) {
                              _expanded.remove(id);
                            } else {
                              _expanded.add(id);
                            }
                          }),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool dark;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.dark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.brand : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.brand
                : dark
                    ? AppColors.darkDivider
                    : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.tabInactive,
          ),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final ScanRecord record;
  final bool expanded;
  final dynamic t;
  final String lang;
  final bool dark;
  final Color textColor;
  final Color subColor;
  final Color cardColor;
  final VoidCallback onToggle;

  const _HistoryTile({
    required this.record,
    required this.expanded,
    required this.t,
    required this.lang,
    required this.dark,
    required this.textColor,
    required this.subColor,
    required this.cardColor,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isScam = record.isScam;
    final tagColor = isScam ? AppColors.red : AppColors.green;
    final tagBg = isScam
        ? (dark ? AppColors.darkSurface : AppColors.lightRed)
        : (dark ? AppColors.darkSurface : AppColors.lightGreen);
    final date = DateFormat('MMM dd, hh:mm a')
        .format(DateTime.fromMillisecondsSinceEpoch(record.timestamp));
    final sender = record.phoneNumber ?? t('unknown_number');

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: tagBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isScam ? Icons.gpp_bad_rounded : Icons.verified_user_rounded,
                color: tagColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          sender,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: tagBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isScam ? t('scam_tag') : t('safe_tag'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: tagColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    record.message,
                    maxLines: expanded ? null : 1,
                    overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13.5, color: subColor, height: 1.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$date Â· ${(record.confidence * 100).round()}% scam',
                    style: TextStyle(fontSize: 11.5, color: subColor),
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
