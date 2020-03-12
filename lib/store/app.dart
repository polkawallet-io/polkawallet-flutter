import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';
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
  AccountStore account = AccountStore();

  @observable
  AssetsStore assets;

  @observable
  StakingStore staking;

  @observable
  GovernanceStore gov;

  @observable
  SettingsStore settings = SettingsStore();

  @observable
  bool isReady = false;

  @action
  Future<void> init() async {
    // wait settings store loaded
    await settings.init();

    account.loadAccount();
    assets = AssetsStore(account);
    staking = StakingStore(account);
    gov = GovernanceStore(account);

    isReady = true;
  }
}
