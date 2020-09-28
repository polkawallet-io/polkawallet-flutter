import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/BorderedTitle.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/passwordInputDialog.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page/account/scanPage.dart';
import 'package:polka_wallet/page/account/uos/qrSignerPage.dart';
import 'package:polka_wallet/page/assets/asset/assetPage.dart';
import 'package:polka_wallet/page/assets/claim/attestPage.dart';
import 'package:polka_wallet/page/assets/claim/claimPage.dart';
import 'package:polka_wallet/page/assets/receive/receivePage.dart';
import 'package:polka_wallet/service/notification.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/service/walletApi.dart';
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
    if (store.settings.endpointIsEncointer) {
      await Future.wait([
        webApi.assets.fetchBalance(),
      ]);
    } else {
      await Future.wait([
        webApi.assets.fetchBalance(),
      ]);
    }
    webApi.account.fetchAccountsIndex();
  }

  Future<List> _fetchAnnouncements() async {
    if (store.assets.announcements != null) return store.assets.announcements;
    final List res = await WalletApi.getAnnouncements();
    store.assets.setAnnouncements(res);
    return res;
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
    String symbol = store.settings.networkState.tokenSymbol;
    BalancesInfo balancesInfo = store.assets.balances[symbol];
    bool aboveLimit = false;
    setState(() {
      _faucetSubmitting = true;
    });

    var res;
    if (balancesInfo.freeBalance -
            Fmt.tokenInt('0.0001', encointerTokenDecimals) >
        BigInt.zero) {
      aboveLimit = true;
    } else {
      res = await webApi.encointer.sendFaucetTx();
    }

    Timer(Duration(seconds: 3), () {
      String dialogContent = I18n.of(context).encointer['faucet.ok'];
      bool isOK = false;
      if (aboveLimit) {
        dialogContent = I18n.of(context).encointer['faucet.limit'];
      } else if (res == null || res["error"] != null) {
        dialogContent = I18n.of(context).encointer['faucet.error'];

        if (res["error"] == "balances.InsufficientBalance") {
          dialogContent +=
              "\nError: ${I18n.of(context).encointer['faucet.insufficientBalance']}";
        } else {
          dialogContent += "\nError: ${res["error"]}";
        }
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
                    print("Faucet ERrror" + res["error"].toString());
                    NotificationPlugin.showNotification(
                      int.parse(res['params'][
                          1]), // todo: Id is used to group notifications. This is probably not a good idea
                      I18n.of(context).assets['notify.receive'],
                      'ERT ' +
                          Fmt.balance(res['params'][1], encointerTokenDecimals)
                              .toString(),
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

    bool isKusama = store.settings.endpoint.info == networkEndpointKusama.info;
    bool isPolkadot =
        store.settings.endpoint.info == networkEndpointPolkadot.info;
    bool isEncointer = store.settings.endpointIsEncointer;

    final accInfo = store.account.accountIndexMap[acc.address];
    final String accIndex = accInfo != null && accInfo['accountIndex'] != null
        ? '${accInfo['accountIndex']}\n'
        : '';
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
                            _getTokensFromFaucet();
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
            title: Row(
              children: [
                GestureDetector(
                  child: Padding(
                    padding: EdgeInsets.only(left: 2),
                    child: Image.asset(
                      'assets/images/assets/qrcode_${store.settings.endpoint.color ?? 'pink'}.png',
                      width: 24,
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
                  child: Text(
                    '$accIndex${Fmt.address(store.account.currentAddress)}',
                    style: TextStyle(fontSize: 14),
                  ),
                )
              ],
            ),
            trailing: IconButton(
              icon: Image.asset(
                  'assets/images/assets/qrcode_${isEncointer ? 'indigo' : isKusama ? 'pink' : 'pink'}.png'),
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

    if (!store.settings.loading && store.settings.networkName != null) {
      webApi.encointer.getBalances();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).home;
    return Observer(
      builder: (_) {
        String symbol = store.settings.networkState.tokenSymbol ?? '';

        int decimals = store.settings.endpointIsEncointer
            ? encointerTokenDecimals
            : store.settings.networkState.tokenDecimals ??
                kusama_token_decimals;
        String networkName = store.settings.networkName ?? '';
        final String tokenView = Fmt.tokenView(symbol);

        List<String> currencyIds = [];
        if (store.settings.endpointIsEncointer && networkName != null) {
          if (store.settings.networkConst['currencyIds'] != null) {
            currencyIds.addAll(
                List<String>.from(store.settings.networkConst['currencyIds']));
          }
          currencyIds.retainWhere((i) => i != symbol);
        }

        Map<String, BalanceEntry> nonZeroEncointerEntries = store
            .encointer.balanceEntries
          ..removeWhere((key, value) => value.principal == 0);

        BalancesInfo balancesInfo = store.assets.balances[symbol];
        return RefreshIndicator(
          key: globalBalanceRefreshKey,
          onRefresh: _fetchBalance,
          child: Column(
            children: <Widget>[
              _buildTopCard(context),
              Container(height: 24),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          BorderedTitle(
                            title: I18n.of(context).home['assets'],
                          ),
                        ],
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
                        title: Text(tokenView),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              Fmt.priceFloorBigInt(
                                  balancesInfo != null
                                      ? balancesInfo.total
                                      : BigInt.zero,
                                  decimals,
                                  lengthFixed: 3),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black54),
                            ),
                            Container(width: 16),
                          ],
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, AssetPage.route,
                              arguments: AssetPageParams(token: symbol));
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
                              child: CircleAvatar(
                                child: Text(token.substring(0, 2)),
                              ),
                            ),
                            title: Text(token),
                            trailing: Text(
                              Fmt.priceFloorBigInt(
                                  Fmt.balanceInt(store.assets.tokenBalances[i]),
                                  decimals,
                                  lengthFixed: 3),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black54),
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, AssetPage.route,
                                  arguments: AssetPageParams(token: token));
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    store.settings.endpointIsEncointer &&
                            nonZeroEncointerEntries.isNotEmpty
                        ? Column(
                            children: nonZeroEncointerEntries.entries
                                .map((balanceData) {
//                        print("balance data: " + balanceData.toString());
                              var cid = balanceData.key;
                              var balanceEntry = balanceData.value;
                              return RoundedCard(
                                margin: EdgeInsets.only(top: 16),
                                child: ListTile(
                                  leading: Container(
                                    width: 36,
                                    child: Image.asset(
                                        'assets/images/assets/ERT.png'),
                                  ),
                                  title: Text(Fmt.currencyIdentifier(cid)),
                                  trailing: Text(
                                    Fmt.doubleFormat(balanceEntry.principal),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.black54),
                                  ),
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, AssetPage.route,
                                        arguments: AssetPageParams(
                                            token: cid,
                                            isEncointerCommunityCurrency:
                                                true));
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
