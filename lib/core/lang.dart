import 'package:flutter/widgets.dart';

import 'strings.dart';

export 'strings.dart';

class LangScope extends InheritedWidget {
  final String language;

  const LangScope({
    super.key,
    required this.language,
    required super.child,
  });

  String t(String key) => S.t(key, lang: language);

  @override
  bool updateShouldNotify(LangScope oldWidget) =>
      oldWidget.language != language;

  static LangScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LangScope>()!;
}
