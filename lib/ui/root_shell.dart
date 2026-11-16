import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/lang.dart';
import 'home.dart';
import 'history.dart';
import 'profile.dart';
import 'scan.dart';

class RootShell extends StatefulWidget {
  final ThemeController controller;

  const RootShell({super.key, required this.controller});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final lang = LangScope.of(context).language;
    final t = (String key) => S.t(key, lang: lang);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final navBg = dark
        ? AppColors.darkCard.withOpacity(0.65)
        : Colors.white.withOpacity(0.65);
    final navBorder = dark
        ? AppColors.darkDivider.withOpacity(0.6)
        : Colors.white.withOpacity(0.55);
    final inactive = dark
        ? const Color(0xFFDCC9CF)
        : AppColors.textSlate500;
    final active = AppColors.brand;

    final screens = [
      _page(
        0,
        HomeScreen(
          onGoScan: () => setState(() => _index = 1),
          onGoProfile: () => setState(() => _index = 3),
          onGoHistory: () => setState(() => _index = 2),
          active: _index == 0,
        ),
      ),
      _page(1, ScanScreen()),
      _page(2, HistoryScreen()),
      _page(
        3,
        ProfileScreen(
          controller: widget.controller,
          onGoScan: () => setState(() => _index = 1),
          onGoHistory: () => setState(() => _index = 2),
          onRefresh: () => setState(() {}),
        ),
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const gap = 90.0;
              final w = constraints.maxWidth;
              // Reserved gap sits between Home and History; keep the scan
              // button exactly centered inside that gap so it can never
              // overlap the History or Home items.
              final homeW = (w - 12 - gap) / 3;
              final scanCenter = 6 + homeW + gap / 2;
              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(dark ? 0.45 : 0.14),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: navBg,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: navBorder),
                          ),
                          child: SizedBox(
                            height: 66,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _NavItem(
                                    icon: Icons.home_rounded,
                                    label: t('nav_home'),
                                    active: _index == 0,
                                    color: _index == 0 ? active : inactive,
                                    onTap: () => setState(() => _index = 0),
                                  ),
                                ),
                                const SizedBox(width: gap),
                                Expanded(
                                  child: _NavItem(
                                    icon: Icons.history_rounded,
                                    label: t('nav_history'),
                                    active: _index == 2,
                                    color: _index == 2 ? active : inactive,
                                    onTap: () => setState(() => _index = 2),
                                  ),
                                ),
                                Expanded(
                                  child: _NavItem(
                                    icon: Icons.person_outline_rounded,
                                    label: t('nav_profile'),
                                    active: _index == 3,
                                    color: _index == 3 ? active : inactive,
                                    onTap: () => setState(() => _index = 3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: scanCenter - 32,
                    child: Transform.translate(
                      offset: const Offset(0, -16),
                      child: _ScanButton(
                        active: _index == 1,
                        onTap: () => setState(() => _index = 1),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Fade + rise transition for tab switches while keeping screen state
  /// alive (IndexedStack).
  Widget _page(int i, Widget screen) {
    final selected = _index == i;
    return IgnorePointer(
      ignoring: !selected,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        opacity: selected ? 1 : 0,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          offset: selected ? Offset.zero : const Offset(0, 0.04),
          child: screen,
        ),
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;

  const _ScanButton({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: active ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.elasticOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: 56,
            height: 56,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.brandBright, AppColors.brandDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: dark ? AppColors.darkBg : Colors.white,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brand.withOpacity(active ? 0.65 : 0.5),
                  blurRadius: active ? 22 : 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.manage_search_rounded,
              color: Colors.white,
              size: 27,
            ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? (dark
                  ? AppColors.brand.withOpacity(0.22)
                  : AppColors.brand.withOpacity(0.10))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: active ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: child,
                ),
                child: Icon(
                  active
                      ? _filledIcon(icon)
                      : icon,
                  key: ValueKey('$icon-$active'),
                  color: active ? color : color.withOpacity(0.85),
                  size: 23,
                ),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 240),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: active ? color : color.withOpacity(0.85),
                letterSpacing: active ? 0.2 : 0,
                fontFamily: 'Inter',
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _filledIcon(IconData outline) {
    if (outline == Icons.home_rounded) return Icons.home_rounded;
    if (outline == Icons.history_rounded) return Icons.history_rounded;
    if (outline == Icons.person_outline_rounded) return Icons.person_rounded;
    return outline;
  }
}
