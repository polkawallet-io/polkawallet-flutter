import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;

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
    'en': {'home': enHome},
    'zh': {'home': zhHome},
  };

  Map<String, String> get home {
    return _localizedValues[locale.languageCode]['home'];
  }
}

const Map<String, String> enHome = {
  'assets': 'Assets',
  'staking': 'Staking',
  'democracy': 'Democracy',
  'profile': 'Profile',
  'account': 'Account',
  'menu': 'Menu',
  'scan': 'Add via Qr',
  'create': 'Create Account',
  'import': 'Import Account',
  'name': 'Name',
  'password': 'Password',
  'password2': 'Confirm Password',
  'next': 'Next',
};

const Map<String, String> zhHome = {
  'assets': '资产',
  'staking': '抵押',
  'democracy': '民主',
  'profile': '设置',
  'account': '账户',
  'menu': '菜单',
  'scan': '通过二维码导入',
  'create': '新建账户',
  'import': '导入账户',
  'name': '账户名',
  'password': '密码',
  'password2': '确认密码',
  'next': '下一步',
};
