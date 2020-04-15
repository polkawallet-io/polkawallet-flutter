import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';
import 'package:polka_wallet/store/acala/acala.dart';
import 'package:polka_wallet/store/settings.dart';
import 'package:polka_wallet/store/staking.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/store/assets.dart';
import 'package:polka_wallet/store/governance.dart';

part 'app.g.dart';

final AppStore globalAppStore = AppStore();

class AppStore extends _AppStore with _$AppStore {}

abstract class _AppStore with Store {
  @observable
  SettingsStore settings = SettingsStore();

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
  bool isReady = false;

  @action
  Future<void> init(String sysLocaleCode) async {
    // wait settings store loaded
    await settings.init(sysLocaleCode);

    account = AccountStore(this);
    await account.loadAccount();

    assets = AssetsStore(this);
    staking = StakingStore(account);
    gov = GovernanceStore(account);

    assets.loadCache();
    staking.loadCache();
    gov.loadCache();

    acala = AcalaStore(this);
    acala.loadCache();

    isReady = true;
  }
}
