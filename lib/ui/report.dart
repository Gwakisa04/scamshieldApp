import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/fraud_types.dart';
import '../core/lang.dart';
import '../core/store.dart';
import '../core/theme.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _numberController = TextEditingController();
  final _messageController = TextEditingController();
  final _api = ScamApiClient();

  String _channel = 'sms';
  int _categoryId = 1;
  int _subtypeIndex = 0;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _numberController.dispose();
    _messageController.dispose();
    super.dispose();
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

    final category = fraudCategories.firstWhere((c) => c.id == _categoryId);
    final subtypeLabel = lang == 'sw'
        ? category.subtypes[_subtypeIndex].sw
        : category.subtypes[_subtypeIndex].en;

    return Scaffold(
      backgroundColor: dark ? AppColors.darkBg : AppColors.bgApp,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        elevation: 0,
        title: Text(t('svc_report_title')),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.brandSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.campaign_rounded,
                          color: AppColors.brand, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        t('report_subtitle'),
                        style: TextStyle(fontSize: 13, height: 1.5, color: subColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _numberController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                      color: dark ? AppColors.darkText : AppColors.inputText,
                      fontSize: 15),
                  decoration: InputDecoration(
                    labelText: t('report_number_label'),
                    hintText: t('report_number_hint'),
                    prefixIcon: Icon(Icons.phone_iphone_rounded,
                        color: subColor, size: 20),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  t('report_channel_label'),
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textColor),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _ChannelChip(
                        icon: Icons.sms_rounded,
                        label: t('report_channel_sms'),
                        selected: _channel == 'sms',
                        onTap: () => setState(() => _channel = 'sms'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ChannelChip(
                        icon: Icons.call_rounded,
                        label: t('report_channel_call'),
                        selected: _channel == 'call',
                        onTap: () => setState(() => _channel = 'call'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  t('report_category_label'),
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textColor),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in fraudCategories)
                      _CategoryChip(
                        icon: c.icon,
                        label: lang == 'sw' ? c.sw : c.en,
                        selected: c.id == _categoryId,
                        onTap: () => setState(() {
                          _categoryId = c.id;
                          _subtypeIndex = 0;
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: subtypeLabel,
                  dropdownColor: cardColor,
                  icon: Icon(Icons.expand_more_rounded, color: subColor),
                  decoration: InputDecoration(
                    labelText: t('report_subtype_label'),
                    prefixIcon: Icon(category.icon, color: subColor, size: 20),
                  ),
                  items: [
                    for (final st in category.subtypes)
                      DropdownMenuItem(
                        value: lang == 'sw' ? st.sw : st.en,
                        child: Text(lang == 'sw' ? st.sw : st.en,
                            style: TextStyle(
                                fontSize: 13.5,
                                color: textColor,
                                overflow: TextOverflow.ellipsis)),
                      ),
                  ],
                  onChanged: (v) {
                    final idx = category.subtypes
                        .indexWhere((s) => (lang == 'sw' ? s.sw : s.en) == v);
                    if (idx >= 0) setState(() => _subtypeIndex = idx);
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: divider),
                  ),
                  child: TextField(
                    controller: _messageController,
                    maxLines: 5,
                    style: TextStyle(
                        color: dark ? AppColors.darkText : AppColors.inputText,
                        fontSize: 14,
                        height: 1.5),
                    decoration: InputDecoration(
                      labelText: t('report_paste_label'),
                      hintText: t('report_paste_hint'),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style: const TextStyle(
                          color: AppColors.red, fontSize: 13)),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brand,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed:
                      _submitting ? null : () => _submit(context, t, lang),
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(t('report_submit'),
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(
      BuildContext context, String Function(String) t, String lang) async {
    setState(() => _error = null);
    final raw = _numberController.text.trim();
    if (raw.length < 7) {
      setState(() => _error = t('report_invalid_number'));
      return;
    }
    final category = fraudCategories.firstWhere((c) => c.id == _categoryId);
    final subtype = lang == 'sw'
        ? category.subtypes[_subtypeIndex].sw
        : category.subtypes[_subtypeIndex].en;

    setState(() => _submitting = true);
    try {
      final ack = await _api.reportNumber(
        phoneNumber: raw,
        category: _categoryId,
        subtype: subtype,
        channel: _channel,
        messageSample: _messageController.text,
      );
      await AppStore.instance.saveScamNumber(
        ack.phoneNumber,
        (lang == 'sw' ? category.sw : category.en),
        channel: _channel,
        subtype: subtype,
        messageSample: _messageController.text.trim().isEmpty
            ? null
            : _messageController.text.trim(),
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(ctx).brightness == Brightness.dark
              ? AppColors.darkCard
              : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppColors.green, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(t('report_thanks_title'),
                    style: const TextStyle(fontSize: 17)),
              ),
            ],
          ),
          content: Text(t('report_thanks_body'),
              style: const TextStyle(fontSize: 14, height: 1.5)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      setState(() {
        _error = t('report_error');
        _submitting = false;
      });
    }
  }
}

class _ChannelChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChannelChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.brand.withOpacity(0.10)
              : (dark ? AppColors.darkSurface : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.brand
                : (dark ? AppColors.darkDivider : AppColors.divider),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: selected ? AppColors.brand : AppColors.textSlate500),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? AppColors.brand
                      : (dark ? AppColors.darkTextSecondary : AppColors.textSlate500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.brand
              : (dark ? AppColors.darkSurface : Colors.white),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected
                ? AppColors.brand
                : (dark ? AppColors.darkDivider : AppColors.divider),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: selected
                    ? Colors.white
                    : (dark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSlate500)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : (dark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSlate500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
