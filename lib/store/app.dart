import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';
import 'package:polka_wallet/service/api.dart';
import 'package:polka_wallet/store/settings.dart';
import 'package:polka_wallet/store/staking.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/store/assets.dart';
import 'package:polka_wallet/store/governance.dart';

part 'app.g.dart';

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

  Api api;

  @action
  void init(BuildContext context) {
    settings.init();
    account.loadAccount();
    assets = AssetsStore(account);
    staking = StakingStore(account);
    gov = GovernanceStore(account);

    api = Api(
        context: context,
        accountStore: account,
        assetsStore: assets,
        stakingStore: staking,
        govStore: gov,
        settingsStore: settings);
    api.init();
  }
}
