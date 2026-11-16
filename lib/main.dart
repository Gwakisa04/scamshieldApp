import 'package:flutter/material.dart';

import 'core/lang.dart';
import 'core/store.dart';
import 'core/theme.dart';
import 'services/guard.dart';
import 'ui/onboarding.dart';
import 'ui/root_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = AppStore.instance;
  await store.init();
  await GuardService.init();
  runApp(ScamShieldApp(
    dark: store.darkTheme,
    language: store.language,
  ));
}

class ScamShieldApp extends StatefulWidget {
  final bool dark;
  final String language;

  const ScamShieldApp({super.key, required this.dark, required this.language});

  @override
  State<ScamShieldApp> createState() => _ScamShieldAppState();
}

class _ScamShieldAppState extends State<ScamShieldApp> {
  late ThemeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ThemeController(dark: widget.dark, language: widget.language);
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    AppStore.instance.setDarkTheme(_controller.dark);
    AppStore.instance.setLanguage(_controller.language);
    setState(() {});
  }

  ThemeData _buildTheme(bool dark) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: dark ? Brightness.dark : Brightness.light,
      primary: AppColors.brand,
      secondary: AppColors.brandBright,
      surface: dark ? AppColors.darkCard : AppColors.surfaceCard,
      error: AppColors.red,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: dark ? AppColors.darkBg : AppColors.bgApp,
      fontFamily: 'Inter',
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? AppColors.darkBg : Colors.white,
        foregroundColor: dark ? AppColors.darkText : AppColors.textSlate900,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: dark ? AppColors.darkText : AppColors.textSlate900,
        ),
      ),
      cardTheme: CardThemeData(
        color: dark ? AppColors.darkCard : AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: dark ? AppColors.darkDivider : AppColors.divider),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? AppColors.darkSurface : Colors.white,
        hintStyle: TextStyle(color: AppColors.inputHint),
        labelStyle: TextStyle(
            color: dark ? AppColors.darkTextSecondary : AppColors.textSlate500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: dark ? AppColors.darkDivider : AppColors.inputStroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: dark ? AppColors.darkDivider : AppColors.inputStroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.brand, width: 1.6),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.brand
                : (dark ? AppColors.darkDivider : AppColors.divider)),
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? Colors.white
                : (dark ? AppColors.darkTextSecondary : Colors.white)),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.brand,
        unselectedLabelColor: AppColors.tabInactive,
        indicatorColor: AppColors.brand,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark ? AppColors.darkSurface : AppColors.textSlate900,
        contentTextStyle: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: dark ? AppColors.darkCard : Colors.white,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: dark ? AppColors.darkText : AppColors.textSlate900,
        ),
        contentTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          height: 1.5,
          color: dark ? AppColors.darkTextSecondary : AppColors.textSlate500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScamShield',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(false),
      darkTheme: _buildTheme(true),
      themeMode: _controller.dark ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) {
        child = LangScope(
          language: _controller.language,
          child: child ?? const SizedBox.shrink(),
        );
        return _PhoneFrame(child: child);
      },
      home: AppStore.instance.onboardingComplete
          ? RootShell(controller: _controller)
          : OnboardingScreen(controller: _controller),
    );
  }
}

class _PhoneFrame extends StatelessWidget {
  final Widget child;

  const _PhoneFrame({required this.child});

  static const _phoneWidth = 412.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= _phoneWidth + 24) {
          return child;
        }
        final phoneHeight = (constraints.maxHeight - 32).clamp(480.0, 892.0);
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.brandDeep, AppColors.brandDark, AppColors.brandDeep],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.black87, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 40,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(29),
              child: SizedBox(
                width: _phoneWidth,
                height: phoneHeight,
                child: MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(size: Size(_phoneWidth, phoneHeight)),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
