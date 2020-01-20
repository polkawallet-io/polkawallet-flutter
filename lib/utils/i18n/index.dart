import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;

import 'home.dart';
import 'account.dart';
import 'profile.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<I18n> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  @override
  Future<I18n> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of DemoLocalizations.
    return SynchronousFuture<I18n>(I18n(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

class I18n {
  I18n(this.locale);

  final Locale locale;

  static I18n of(BuildContext context) {
    return Localizations.of<I18n>(context, I18n);
  }

  static Map<String, Map<String, Map<String, String>>> _localizedValues = {
    'en': {'home': enHome, 'account': enAccount, 'profile': enProfile},
    'zh': {'home': zhHome, 'account': zhAccount, 'profile': zhProfile},
  };

  Map<String, String> get home {
    return _localizedValues[locale.languageCode]['home'];
  }

  Map<String, String> get account {
    return _localizedValues[locale.languageCode]['account'];
  }

  Map<String, String> get profile {
    return _localizedValues[locale.languageCode]['profile'];
  }
}
