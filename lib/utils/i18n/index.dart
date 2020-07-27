import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:polka_wallet/utils/i18n/assets.dart';
import 'package:polka_wallet/utils/i18n/acala.dart';
import 'package:polka_wallet/utils/i18n/laminar.dart';
import 'package:polka_wallet/utils/i18n/staking.dart';
import 'package:polka_wallet/utils/i18n/gov.dart';

import 'home.dart';
import 'account.dart';
import 'profile.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<I18n> {
  const AppLocalizationsDelegate(this.overriddenLocale);

  final Locale overriddenLocale;

  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  @override
  Future<I18n> load(Locale locale) {
    return SynchronousFuture<I18n>(I18n(overriddenLocale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => true;
}

class I18n {
  I18n(this.locale);

  final Locale locale;

  static I18n of(BuildContext context) {
    return Localizations.of<I18n>(context, I18n);
  }

  static Map<String, Map<String, Map<String, String>>> _localizedValues = {
    'en': {
      'home': enHome,
      'account': enAccount,
      'assets': enAssets,
      'staking': enStaking,
      'profile': enProfile,
      'gov': enGov,
      'acala': enDex,
      'laminar': enLaminar,
    },
    'zh': {
      'home': zhHome,
      'account': zhAccount,
      'assets': zhAssets,
      'staking': zhStaking,
      'profile': zhProfile,
      'gov': zhGov,
      'acala': zhDex,
      'laminar': zhLaminar,
    },
  };

  Map<String, String> get home {
    return _localizedValues[locale.languageCode]['home'];
  }

  Map<String, String> get account {
    return _localizedValues[locale.languageCode]['account'];
  }

  Map<String, String> get assets {
    return _localizedValues[locale.languageCode]['assets'];
  }

  Map<String, String> get staking {
    return _localizedValues[locale.languageCode]['staking'];
  }

  Map<String, String> get profile {
    return _localizedValues[locale.languageCode]['profile'];
  }

  Map<String, String> get gov {
    return _localizedValues[locale.languageCode]['gov'];
  }

  Map<String, String> get acala {
    return _localizedValues[locale.languageCode]['acala'];
  }

  Map<String, String> get laminar {
    return _localizedValues[locale.languageCode]['laminar'];
  }
}
