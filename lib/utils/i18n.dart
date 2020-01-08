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
    'en': {'home': enHome, 'account': enAccount},
    'zh': {'home': zhHome, 'account': zhAccount},
  };

  Map<String, String> get home {
    return _localizedValues[locale.languageCode]['home'];
  }

  Map<String, String> get account {
    return _localizedValues[locale.languageCode]['account'];
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
  'next': 'Next Step',
  'ok': 'OK',
  'cancel': 'Cancel',
};

const Map<String, String> enAccount = {
  'create.name': 'Name',
  'create.name.error': 'Name can not be empty',
  'create.password': 'Password',
  'create.password.error': 'At least 6 digits and contains numbers and letters',
  'create.password2': 'Confirm Password',
  'create.password2.error': 'Inconsistent passwords',
  'create.warn1': 'Backup prom',
  'create.warn2': 'Getting a mnemonic equals ownership of a wallet asset',
  'create.warn3': 'Backup mnemonic',
  'create.warn4': 'Use paper and pen to correctly copy mnemonics',
  'create.warn5':
      'If your phone is lost, stolen or damaged, the mnemonic will restore your assets',
  'create.warn6': 'Offline storage',
  'create.warn7': 'Keep it safe to a safe place on the isolated network',
  'create.warn8':
      'Do not share and store mnemonics in a networked environment, such as emails, photo albums, social applications',
  'create.warn9': 'Do not take screenshots',
  'create.warn10':
      'Do not take screenshots, which may be collected by third-party malware, resulting in asset loss',
  'backup': 'Confirm the mnemonic',
  'backup.confirm':
      'Please click on the mnemonic in the correct order to confirm that the backup is correct',
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
  'next': '下一步',
  'ok': '确认',
  'cancel': '取消',
};

const Map<String, String> zhAccount = {
  'create.name': '账户名',
  'create.name.error': '账户名不能为空',
  'create.password': '密码',
  'create.password.error': '密码至少6位，且包含数字和字母',
  'create.password2': '确认密码',
  'create.password2.error': '密码不一致',
  'create.warn1': '备份提示',
  'create.warn2': '获得助记词等于拥有钱包资产所有权',
  'create.warn3': '备份助记词',
  'create.warn4': '使用纸和笔正确抄写助记词',
  'create.warn5': '如果你的手机丢失、被盗、损坏，助记词将可以恢复你的资产',
  'create.warn6': '离线保存',
  'create.warn7': '妥善保管至隔离网络的安全地方',
  'create.warn8': '请勿将助记词在联网环境下分享和储存，比如邮件、相册、社交应用等',
  'create.warn9': '请勿截屏',
  'create.warn10': '请勿截屏分享和储存，这将可能被第三方恶意软件收集，造成资产损失',
  'backup': '确认助记词',
  'backup.confirm': '请按正确顺序点击助记词，以确认备份正确',
};
