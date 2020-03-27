import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page/assets/asset/assetPage.dart';
import 'package:polka_wallet/page/assets/receive/receivePage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/common/components/BorderedTitle.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';

import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class Assets extends StatefulWidget {
  Assets(this.store);

  final AppStore store;

  @override
  _AssetsState createState() => _AssetsState(store);
}

class _AssetsState extends State<Assets> {
  _AssetsState(this.store);

  final AppStore store;

  Future<void> _fetchBalance() async {
    if (store.settings.endpoint.info == networkEndpointAcala.info) {
      await Future.wait([
        webApi.assets.fetchBalance(store.account.currentAccount.pubKey),
        webApi.acalaAssets.fetchTokens(store.account.currentAccount.pubKey),
      ]);
    } else {
      await Future.wait([
        webApi.assets.fetchBalance(store.account.currentAccount.pubKey),
        webApi.staking.fetchAccountStaking(store.account.currentAccount.pubKey),
      ]);
    }
  }

  Widget _buildTopCard(BuildContext context) {
    var dic = I18n.of(context).assets;
    String network = store.settings.loading
        ? dic['node.connecting']
        : store.settings.networkName ?? dic['node.failed'];

    AccountData acc = store.account.currentAccount;

    bool isAcala = store.settings.endpoint.info == networkEndpointAcala.info;

    return RoundedCard(
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: AddressIcon('', pubKey: acc.pubKey),
            title: Text(acc.name ?? ''),
            subtitle: Text(network),
          ),
          ListTile(
            title: Text(Fmt.address(store.account.currentAddress)),
            trailing: IconButton(
              icon: Image.asset(
                  'assets/images/assets/qrcode_${isAcala ? 'indigo' : 'pink'}.png'),
              onPressed: () {
                if (acc.address != '') {
                  Navigator.pushNamed(context, ReceivePage.route);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    // if network connected failed, reconnect
    if (!store.settings.loading && store.settings.networkName == null) {
      store.settings.setNetworkLoading(true);
      webApi.connectNode();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        String symbol = store.settings.networkState.tokenSymbol;
        String networkName = store.settings.networkName;

        List<String> currencyIds = [];
        if (store.settings.endpoint.info == networkEndpointAcala.info) {
          currencyIds.addAll(
              List<String>.from(store.settings.networkConst['currencyIds']));
          currencyIds.retainWhere((i) => i != symbol);
          print(currencyIds);
        }
        return RefreshIndicator(
          key: globalBalanceRefreshKey,
          onRefresh: _fetchBalance,
          child: ListView(
            padding: EdgeInsets.only(left: 16, right: 16),
            children: <Widget>[
              _buildTopCard(context),
              Padding(
                padding: EdgeInsets.only(top: 32),
                child: BorderedTitle(
                  title: I18n.of(context).home['assets'],
                ),
              ),
              RoundedCard(
                margin: EdgeInsets.only(top: 16),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    child: Image.asset(
                        'assets/images/assets/${symbol.isNotEmpty ? symbol : 'DOT'}.png'),
                  ),
                  title: Text(symbol ?? ''),
                  subtitle: Text(networkName ?? '~'),
                  trailing: Text(
                    Fmt.balance(store.assets.balance,
                        decimals: store.settings.networkState.tokenDecimals),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black54),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, AssetPage.route);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
