import 'package:encointer_wallet/utils/translations/translationsHome.dart';
import 'package:encointer_wallet/utils/translations/translationsAccount.dart';
import 'package:encointer_wallet/utils/translations/translationsAssets.dart';
import 'package:encointer_wallet/utils/translations/translationsProfile.dart';
import 'package:encointer_wallet/utils/translations/translationsEncointer.dart';
import 'package:encointer_wallet/utils/translations/translationsBazaar.dart';

/// top level contains groups like 'account', 'profile' etc.
/// (when you add a new group the compiler will force you to add it in all implementations, too.)
abstract class Translations {
  TranslationsHome get home;
  TranslationsAccount get account;
  TranslationsAssets get assets;
  TranslationsProfile get profile;
  TranslationsEncointer get encointer;
  TranslationsBazaar get bazaar;
}

/// for english translations
class TranslationsEn implements Translations {
  TranslationsHome get home => TranslationsEnHome();
  TranslationsAccount get account => TranslationsEnAccount();
  TranslationsAssets get assets => TranslationsEnAssets();
  TranslationsProfile get profile => TranslationsEnProfile();
  TranslationsEncointer get encointer => TranslationsEnEncointer();
  TranslationsBazaar get bazaar => TranslationsEnBazaar();
}

/// for german translations
class TranslationsDe implements Translations {
  TranslationsHome get home => TranslationsDeHome();
  TranslationsAccount get account => TranslationsDeAccount();
  TranslationsAssets get assets => TranslationsDeAssets();
  TranslationsProfile get profile => TranslationsDeProfile();
  TranslationsEncointer get encointer => TranslationsDeEncointer();
  TranslationsBazaar get bazaar => TranslationsDeBazaar();
}

/// for chinese translations
class TranslationsZh implements Translations {
  TranslationsHome get home => TranslationsZhHome();
  TranslationsAccount get account => TranslationsZhAccount();
  TranslationsAssets get assets => TranslationsZhAssets();
  TranslationsProfile get profile => TranslationsZhProfile();
  TranslationsEncointer get encointer => TranslationsZhEncointer();
  TranslationsBazaar get bazaar => TranslationsZhBazaar();
}
