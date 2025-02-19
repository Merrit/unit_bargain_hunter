import 'package:flutter/material.dart';

import '../src/generated/i18n/app_localizations.dart';

extension Translate on BuildContext {
  /// Easier access to translations, so you can use `context.translations`
  /// instead of `AppLocalizations.of(context)!`.
  ///
  /// Also means not having to manually add the app_localizations.dart import,
  /// which never works with the IDE suggestions.
  AppLocalizations get translations => AppLocalizations.of(this)!;
}
