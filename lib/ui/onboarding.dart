import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/store.dart';
import '../core/theme.dart';
import '../core/lang.dart';
import '../services/platform.dart';
import 'root_shell.dart';

class OnboardingScreen extends StatelessWidget {
  final ThemeController controller;

  const OnboardingScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final lang = LangScope.of(context).language;
    final t = (String key) => S.t(key, lang: lang);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF380A13),
              AppColors.brandDeep,
              AppColors.brandDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 32),
                  Center(
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.brandBright,
                                AppColors.brandDark,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brandBright.withOpacity(0.45),
                                blurRadius: 26,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.shield_rounded,
                              color: Colors.white, size: 40),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    t('setup_welcome_title'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    t('setup_why_permissions'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.5,
                      color: Colors.white.withOpacity(0.72),
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: _FeatureCard(
                          icon: Icons.notifications_active_rounded,
                          label: t('ob_feat_alerts'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _FeatureCard(
                          icon: Icons.manage_search_rounded,
                          label: t('ob_feat_autoscan'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _FeatureCard(
                          icon: Icons.contacts_rounded,
                          label: t('ob_feat_contacts'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.12),
                      ),
                    ),
                    child: Text(
                      t('setup_permissions_list'),
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.75,
                        color: Colors.white.withOpacity(0.88),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lock_outline,
                          size: 18, color: Colors.white.withOpacity(0.65)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          t('setup_privacy_safe'),
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.5,
                            color: Colors.white.withOpacity(0.65),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.brandDeep,
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => _complete(context, true),
                    child: Text(
                      t('setup_grant_button'),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15.5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => _complete(context, false),
                    child: Text(
                      t('setup_manual_only'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _complete(BuildContext context, bool withProtection) async {
    final store = AppStore.instance;
    await store.setOnboardingComplete(true);
    if (withProtection && isAndroid) {
      await _requestProtectionPermissions();
      await store.setMonitoringEnabled(true);
    }
    if (context.mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => RootShell(controller: controller),
      ));
    }
  }

  /// Contacts first (trust engine), then notifications, then SMS + call watch.
  Future<void> _requestProtectionPermissions() async {
    final store = AppStore.instance;
    final contactsGranted = await Permission.contacts.request().isGranted;
    await store.setContactsAllowed(contactsGranted);
    await store.setNotificationsEnabled(
        await Permission.notification.request().isGranted);
    await Permission.sms.request();
    await Permission.phone.request();
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.brandBright, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
