import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page/assets/asset/assetPage.dart';
import 'package:polka_wallet/page/assets/claim/attestPage.dart';
import 'package:polka_wallet/page/assets/claim/claimPage.dart';
import 'package:polka_wallet/page/assets/receive/receivePage.dart';
import 'package:polka_wallet/service/notification.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/common/components/BorderedTitle.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/store/account/types/accountData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/assets/types/balancesInfo.dart';
import 'package:polka_wallet/store/encointer/types/encointerBalanceData.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';

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

  bool _faucetSubmitting = false;
  bool _preclaimChecking = false;

  Future<void> _fetchBalance() async {
    bool isEncointer = store.settings.endpoint.info == networkEndpointEncointerGesell.info ||
            store.settings.endpoint.info == networkEndpointEncointerGesellDev.info ||
            store.settings.endpoint.info == networkEndpointEncointerCantillon.info;

    if (isEncointer) {
      await Future.wait([
        webApi.assets.fetchBalance(store.account.currentAccount.pubKey),
      ]);
    } else {
      await Future.wait([
        webApi.assets.fetchBalance(store.account.currentAccount.pubKey),
        webApi.staking.fetchAccountStaking(store.account.currentAccount.pubKey),
      ]);
    }
  }


  Future<String> _checkPreclaim() async {
    setState(() {
      _preclaimChecking = true;
    });
    String address = store.account.currentAddress;
    String ethAddress =
        await webApi.evalJavascript('api.query.claims.preclaims("$address")');
    setState(() {
      _preclaimChecking = false;
    });
    if (ethAddress == null) {
      Navigator.of(context).pushNamed(ClaimPage.route, arguments: '');
    } else {
      Navigator.of(context).pushNamed(AttestPage.route, arguments: ethAddress);
    }
    return ethAddress;
  }

  Future<void> _getTokensFromFaucet() async {
    setState(() {
      _faucetSubmitting = true;
    });
/*    String res = await webApi.encointer.fetchFaucet();

    Timer(Duration(seconds: 3), () {
      String dialogContent = I18n.of(context).acala['faucet.ok'];
      bool isOK = false;
      if (res == null) {
        dialogContent = I18n.of(context).acala['faucet.error'];
      } else if (res == "LIMIT") {
        dialogContent = I18n.of(context).acala['faucet.limit'];
      } else {
        isOK = true;
      }
      setState(() {
        _faucetSubmitting = false;
      });

      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Container(),
            content: Text(dialogContent),
            actions: <Widget>[
              CupertinoButton(
                child: Text(I18n.of(context).home['ok']),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (isOK) {
                    globalBalanceRefreshKey.currentState.show();
                    NotificationPlugin.showNotification(
                      int.parse(res.substring(0, 6)),
                      I18n.of(context).assets['notify.receive'],
                      '{"ACA": 2, "aUSD": 2, "DOT": 2, "XBTC": 0.2}',
                    );
                  }
                },
              ),
            ],
          );
        },
      );
    });
  */
  }


  Widget _buildTopCard(BuildContext context) {
    var dic = I18n.of(context).assets;
    String network = store.settings.loading
        ? dic['node.connecting']
        : store.settings.networkName ?? dic['node.failed'];

    AccountData acc = store.account.currentAccount;

    bool isKusama = store.settings.endpoint.info == networkEndpointKusama.info;
    bool isPolkadot =
        store.settings.endpoint.info == networkEndpointPolkadot.info;
    bool isEncointer = store.settings.endpoint.info == networkEndpointEncointerGesell.info ||
        store.settings.endpoint.info == networkEndpointEncointerGesellDev.info ||
        store.settings.endpoint.info == networkEndpointEncointerCantillon.info;

    return RoundedCard(
      margin: EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: AddressIcon('', pubKey: acc.pubKey),
            title: Text(Fmt.accountName(context, acc)),
            subtitle: Text(network),
            trailing: isEncointer
                ? !store.settings.loading
                ? GestureDetector(
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: Column(
                        children: <Widget>[
                          _faucetSubmitting
                              ? CupertinoActivityIndicator()
                              : Icon(
                                  Icons.card_giftcard,
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                          Text(
                            I18n.of(context).encointer['faucet.title'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      if (acc.address != '') {
                        //_getTokensFromFaucet();
                      }
                    },
                  )
                : Container(width: 8)
                : isPolkadot
                    ? !store.settings.loading
                        ? GestureDetector(
                            child: Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Column(
                                children: <Widget>[
                                  _faucetSubmitting
                                      ? CupertinoActivityIndicator()
                                      : Icon(
                                          Icons.card_giftcard,
                                          color: Theme.of(context).primaryColor,
                                          size: 20,
                                        ),
                                  Text(
                                    dic['claim'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            onTap: _preclaimChecking
                                ? null
                                : () {
                                    _checkPreclaim();
                                  },
                          )
                        : Container(width: 8)
                    : Container(width: 8),
          ),
          ListTile(
            title: Text(Fmt.address(store.account.currentAddress)),
            trailing: IconButton(
              icon: Image.asset(
                  'assets/images/assets/qrcode_${isEncointer ? 'indigo' : isKusama ? 'pink800' : 'pink'}.png'),
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
      webApi.connectNodeAll();
    }

    if (!store.settings.loading && store.settings.networkName != null) {
      webApi.encointer.getBalances();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        String symbol = store.settings.networkState.tokenSymbol;
        int decimals = store.settings.networkState.tokenDecimals;
        String networkName = store.settings.networkName ?? '';

        bool isEncointer =
            store.settings.endpoint.info == networkEndpointEncointerGesell.info ||
            store.settings.endpoint.info == networkEndpointEncointerGesellDev.info ||
            store.settings.endpoint.info == networkEndpointEncointerCantillon.info;

        List<String> currencyIds = [];
        if (isEncointer && networkName != null) {
          if (store.settings.networkConst['currencyIds'] != null) {
            currencyIds.addAll(
                List<String>.from(store.settings.networkConst['currencyIds']));
          }
          currencyIds.retainWhere((i) => i != symbol);
        }

        print("encointer balances" + store.encointer.balanceEntries.toString());

        BalancesInfo balancesInfo = store.assets.balances[symbol];
        return RefreshIndicator(
          key: globalBalanceRefreshKey,
          onRefresh: _fetchBalance,
          child: Column(
            children: <Widget>[
              _buildTopCard(context),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: BorderedTitle(
                        title: I18n.of(context).home['assets'],
                      ),
                    ),
                    RoundedCard(
                      margin: EdgeInsets.only(top: 16),
                      child: ListTile(
                        leading: Container(
                          width: 36,
                          child: Image.asset(
                              'assets/images/assets/${symbol.isNotEmpty ? symbol : 'DOT'}.png'),
                        ),
                        title: Text(symbol ?? ''),
                        trailing: Text(
                          Fmt.token(
                              balancesInfo != null
                                  ? balancesInfo.total
                                  : BigInt.zero,
                              decimals: decimals),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black54),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, AssetPage.route,
                              arguments: symbol);
                        },
                      ),
                    ),
                    Column(
                      children: currencyIds.map((i) {
//                  print(store.assets.balances[i]);
                        String token = i;
                        return RoundedCard(
                          margin: EdgeInsets.only(top: 16),
                          child: ListTile(
                            leading: Container(
                              width: 36,
                              child: Image.asset('assets/images/assets/$i.png'),
                            ),
                            title: Text(token),
                            trailing: Text(
                              Fmt.balance(store.assets.tokenBalances[i],
                                  decimals: decimals),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black54),
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, AssetPage.route,
                                  arguments: token);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    store.encointer.balanceEntries.isNotEmpty ?
                    Column(
                      children: store.encointer.balanceEntries.entries.map((balanceData) {
                        print("balance data: " + balanceData.toString());
                        var cid = balanceData.key;
                        var balanceEntry = balanceData.value;
                        return RoundedCard(
                          margin: EdgeInsets.only(top: 16),
                          child: ListTile(
                            leading: Container(
                              width: 36,
                              child: Image.asset('assets/images/assets/ERT.png'),
                            ),
                            title: Text(Fmt.currencyIdentifier(cid)),
                            trailing: Text(
                              Fmt.balance(balanceEntry.principal.toString(),
                                  decimals: decimals),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black54),
                            ),
                            onTap: () {
//                                      Navigator.pushNamed(context, AssetPage.route,
//                                          arguments: token);
                            },
                          ),
                        );
                      }).toList(),
                    )
                        : Container(),
                    Container(
                      padding: EdgeInsets.only(bottom: 32),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
