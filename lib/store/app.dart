import 'package:mobx/mobx.dart';
import 'package:encointer_wallet/store/account/account.dart';
import 'package:encointer_wallet/store/assets/assets.dart';
import 'package:encointer_wallet/store/encointer/encointer.dart';
import 'package:encointer_wallet/store/settings.dart';
import 'package:encointer_wallet/utils/localStorage.dart';

part 'app.g.dart';

AppStore globalAppStore = AppStore(LocalStorage());

class AppStore extends _AppStore with _$AppStore {
  AppStore(LocalStorage localStorage): super(localStorage);
}

abstract class _AppStore with Store {
  _AppStore(this.localStorage);

  @observable
  SettingsStore settings;

  @observable
  AccountStore account;

  @observable
  AssetsStore assets;

  @observable
  EncointerStore encointer;

  @observable
  bool isReady = false;

  LocalStorage localStorage;

  @action
  Future<void> init(String sysLocaleCode) async {
    // wait settings store loaded
    settings = SettingsStore(this);
    await settings.init(sysLocaleCode);

    account = AccountStore(this);
    await account.loadAccount();

    assets = AssetsStore(this);

    assets.loadCache();

    encointer = EncointerStore(this);
    encointer.loadCache();

    isReady = true;
  }
}
