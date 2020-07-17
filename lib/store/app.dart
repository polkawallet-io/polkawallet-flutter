import 'package:mobx/mobx.dart';
import 'package:polka_wallet/store/acala/acala.dart';
import 'package:polka_wallet/store/laminar/laminar.dart';
import 'package:polka_wallet/store/settings.dart';
import 'package:polka_wallet/store/staking/staking.dart';
import 'package:polka_wallet/store/account/account.dart';
import 'package:polka_wallet/store/assets/assets.dart';
import 'package:polka_wallet/store/gov/governance.dart';
import 'package:polka_wallet/utils/localStorage.dart';

part 'app.g.dart';

final AppStore globalAppStore = AppStore();

class AppStore extends _AppStore with _$AppStore {}

abstract class _AppStore with Store {
  @observable
  SettingsStore settings;

  @observable
  AccountStore account;

  @observable
  AssetsStore assets;

  @observable
  StakingStore staking;

  @observable
  GovernanceStore gov;

  @observable
  AcalaStore acala;

  @observable
  LaminarStore laminar;

  @observable
  bool isReady = false;

  LocalStorage localStorage = LocalStorage();

  @action
  Future<void> init(String sysLocaleCode) async {
    // wait settings store loaded
    settings = SettingsStore(this);
    await settings.init(sysLocaleCode);

    account = AccountStore(this);
    await account.loadAccount();

    assets = AssetsStore(this);
    staking = StakingStore(this);
    gov = GovernanceStore(this);

    assets.loadCache();
    staking.loadCache();
    gov.loadCache();

    acala = AcalaStore(this);
    acala.loadCache();
    laminar = LaminarStore(this);
    laminar.loadCache();

    isReady = true;
  }
}
