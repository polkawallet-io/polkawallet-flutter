import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/passwordInputDialog.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page/account/scanPage.dart';
import 'package:polka_wallet/page/account/uos/qrSignerPage.dart';
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
    if (store.settings.endpoint.info == networkEndpointAcala.info ||
        store.settings.endpoint.info == networkEndpointLaminar.info) {
      await webApi.assets.fetchBalance();
    } else {
      await Future.wait([
        webApi.assets.fetchBalance(),
        webApi.staking.fetchAccountStaking(),
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

  Future<void> _handleScan() async {
    final Map dic = I18n.of(context).account;
    final data = await Navigator.pushNamed(
      context,
      ScanPage.route,
      arguments: 'tx',
    );
    if (data != null) {
      if (store.account.currentAccount.observation ?? false) {
        showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: Text(dic['uos.title']),
              content: Text(dic['uos.acc.invalid']),
              actions: <Widget>[
                CupertinoButton(
                  child: Text(I18n.of(context).home['ok']),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
        return;
      }

      final Map sender =
          await webApi.account.parseQrCode(data.toString().trim());
      if (sender['signer'] != store.account.currentAddress) {
        showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: Text(dic['uos.title']),
              content: sender['error'] != null
                  ? Text(sender['error'])
                  : sender['signer'] == null
                      ? Text(dic['uos.qr.invalid'])
                      : Text(dic['uos.acc.mismatch']),
              actions: <Widget>[
                CupertinoButton(
                  child: Text(I18n.of(context).home['ok']),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      } else {
        showCupertinoDialog(
          context: context,
          builder: (_) {
            return PasswordInputDialog(
              account: store.account.currentAccount,
              title: Text(dic['uos.title']),
              onOk: (password) {
                print('pass ok: $password');
                _signAsync(password);
              },
            );
          },
        );
      }
    }
  }

  Future<void> _signAsync(String password) async {
    final Map dic = I18n.of(context).account;
    final Map signed = await webApi.account.signAsync(password);
    print('signed: $signed');
    if (signed['error'] != null) {
      showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: Text(dic['uos.title']),
            content: Text(signed['error']),
            actions: <Widget>[
              CupertinoButton(
                child: Text(I18n.of(context).home['ok']),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
      return;
    }
    Navigator.of(context).pushNamed(
      QrSignerPage.route,
      arguments: signed['signature'].toString().substring(2),
    );
  }

  Future<void> _getTokensFromFaucet() async {
    setState(() {
      _faucetSubmitting = true;
    });
    String res = await webApi.acala.fetchFaucet();

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
  }

  Widget _buildTopCard(BuildContext context) {
    var dic = I18n.of(context).assets;
    String network = store.settings.loading
        ? dic['node.connecting']
        : store.settings.networkName ?? dic['node.failed'];

    AccountData acc = store.account.currentAccount;

    bool isAcala = store.settings.endpoint.info == networkEndpointAcala.info;
    bool isKusama = store.settings.endpoint.info == networkEndpointKusama.info;
    bool isPolkadot =
        store.settings.endpoint.info == networkEndpointPolkadot.info;

    return RoundedCard(
      margin: EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: AddressIcon('', pubKey: acc.pubKey),
            title: Text(Fmt.accountName(context, acc)),
            subtitle: Text(network),
            trailing: isAcala
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
                            I18n.of(context).acala['faucet.title'],
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
                        _getTokensFromFaucet();
                      }
                    },
                  )
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
            title: Row(
              children: [
                GestureDetector(
                  child: Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Image.asset(
                      'assets/images/assets/qrcode_${store.settings.endpoint.color ?? 'pink'}.png',
                      width: 18,
                    ),
                  ),
                  onTap: () {
                    if (acc.address != '') {
                      Navigator.pushNamed(context, ReceivePage.route);
                    }
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(Fmt.address(store.account.currentAddress)),
                )
              ],
            ),
            trailing: IconButton(
              icon: Image.asset(
                  'assets/images/assets/scanner_${store.settings.endpoint.color ?? 'pink'}.png'),
              onPressed: () {
                if (acc.address != '') {
                  _handleScan();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!store.settings.loading) {
        globalBalanceRefreshKey.currentState?.show();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        String symbol = store.settings.networkState.tokenSymbol;
        int decimals = store.settings.networkState.tokenDecimals;
        String networkName = store.settings.networkName ?? '';

        bool isAcala =
            store.settings.endpoint.info == networkEndpointAcala.info;
        bool isLaminar =
            store.settings.endpoint.info == networkEndpointLaminar.info;

        List<String> currencyIds = [];
        if ((isAcala || isLaminar) && networkName != null) {
          if (store.settings.networkConst['currencyIds'] != null) {
            currencyIds.addAll(
                List<String>.from(store.settings.networkConst['currencyIds']));
          }
          currencyIds.retainWhere((i) => i != symbol);
        }

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
                        String token =
                            i == acala_stable_coin ? acala_stable_coin_view : i;

                        bool hasIcon = true;
                        if (isLaminar && token != acala_stable_coin_view) {
                          hasIcon = false;
                        }
                        return RoundedCard(
                          margin: EdgeInsets.only(top: 16),
                          child: ListTile(
                            leading: Container(
                              width: 36,
                              child: hasIcon
                                  ? Image.asset('assets/images/assets/$i.png')
                                  : CircleAvatar(
                                      child: Text(token.substring(0, 2)),
                                    ),
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
                    isAcala && store.acala.airdrops.keys.length > 0
                        ? Padding(
                            padding: EdgeInsets.only(top: 24),
                            child: BorderedTitle(
                              title: I18n.of(context).acala['airdrop'],
                            ),
                          )
                        : Container(),
                    isAcala && store.acala.airdrops.keys.length > 0
                        ? Column(
                            children: store.acala.airdrops.keys.map((i) {
                              return RoundedCard(
                                margin: EdgeInsets.only(top: 16),
                                child: ListTile(
                                  leading: Container(
                                    width: 36,
                                    child: Image.asset(
                                        'assets/images/assets/$i.png'),
                                  ),
                                  title: Text(i),
                                  trailing: Text(
                                    Fmt.token(store.acala.airdrops[i],
                                        decimals: decimals),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.black54),
                                  ),
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
