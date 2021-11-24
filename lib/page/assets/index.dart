import 'dart:async';
import 'dart:ui';

import 'package:encointer_wallet/common/components/BorderedTitle.dart';
import 'package:encointer_wallet/common/components/addressIcon.dart';
import 'package:encointer_wallet/common/components/passwordInputDialog.dart';
import 'package:encointer_wallet/common/components/passwordInputSwitchAccountDialog.dart';
import 'package:encointer_wallet/common/components/roundedCard.dart';
import 'package:encointer_wallet/config/consts.dart';
import 'package:encointer_wallet/page-encointer/common/communityChooserPanel.dart';
import 'package:encointer_wallet/page/account/scanPage.dart';
import 'package:encointer_wallet/page/account/uos/qrSignerPage.dart';
import 'package:encointer_wallet/page/assets/asset/assetPage.dart';
import 'package:encointer_wallet/page/assets/receive/receivePage.dart';
import 'package:encointer_wallet/page/networkSelectPage.dart';
import 'package:encointer_wallet/service/notification.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/account/types/accountData.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/store/assets/types/balancesInfo.dart';
import 'package:encointer_wallet/utils/UI.dart';
import 'package:encointer_wallet/utils/format.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

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
  bool _dialogIsShown = false;

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

      final Map sender = await webApi.account.parseQrCode(data.toString().trim());
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
    if (balancesInfo.freeBalance - Fmt.tokenInt(faucetAmount.toString(), ert_decimals) > BigInt.zero) {
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
          dialogContent += "\nError: ${I18n.of(context).encointer['faucet.insufficientBalance']}";
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
                    print("Faucet Error" + res["error"].toString());
                    NotificationPlugin.showNotification(
                      int.parse(res['params']
                          [1]), // todo: Id is used to group notifications. This is probably not a good idea
                      I18n.of(context).assets['notify.receive'],
                      'ERT ' + Fmt.balance(res['params'][1], ert_decimals).toString(),
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
    String network = store.settings.loading ? dic['node.connecting'] : store.settings.networkName ?? dic['node.failed'];

    AccountData acc = store.account.currentAccount;

    final accInfo = store.account.accountIndexMap[acc.address];
    final String accIndex = accInfo != null && accInfo['accountIndex'] != null ? '${accInfo['accountIndex']}\n' : '';
    return RoundedCard(
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          ListTile(
              leading: AddressIcon('', pubKey: acc.pubKey),
              title: Text(Fmt.accountName(context, acc)),
              subtitle: Text(network),
              trailing: !store.settings.loading
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
                  : Container(width: 8)),
          ListTile(
            title: Row(
              children: [
                GestureDetector(
                  child: Padding(
                    key: Key('qr-receive'),
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
              icon: Image.asset('assets/images/assets/qrcode_indigo.png'),
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

  Future<void> _showPasswordDialog(BuildContext context) async {
    var dic = I18n.of(context).home;
    setState(() {
      _dialogIsShown = true;
    });
    await showCupertinoDialog(
      context: context,
      builder: (_) {
        return WillPopScope(
          child: PasswordInputSwitchAccountDialog(
              title: Text(dic['unlock.account']
                  .replaceAll('CURRENT_ACCOUNT_NAME', store.account.currentAccount.name.toString())),
              account: store.account.currentAccount,
              onOk: (password) {
                setState(() {
                  store.account.setPin(password);
                });
              },
              onSwitch: () async => {
                    Navigator.of(context).pop(),
                    await Navigator.of(context).pushNamed(NetworkSelectPage.route),
                    setState(() {}),
                  }),
          onWillPop: () {
            // handles back button press
            return _showPasswordNotEnteredDialog(context);
          },
        );
      },
    );
    setState(() {
      _dialogIsShown = false;
    });
  }

  Future<void> _showPasswordNotEnteredDialog(BuildContext context) async {
    await showCupertinoDialog(
      context: context,
      builder: (_) {
        return CupertinoAlertDialog(
          title: Text(I18n.of(context).home['pin.needed']),
          actions: <Widget>[
            CupertinoButton(
              child: Text(I18n.of(context).home['cancel']),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoButton(
              child: Text(I18n.of(context).home['close.app']),
              onPressed: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // if network connected failed, reconnect
    if (!store.settings.loading && store.settings.networkName == null) {
      store.settings.setNetworkLoading(true);
      webApi.connectNodeAll();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).assets;
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
      children: [
        Observer(builder: (_) {
          String symbol = store.settings.networkState.tokenSymbol ?? '';

          int decimals = store.settings.networkState.tokenDecimals ?? ert_decimals;
          String networkName = store.settings.networkName ?? '';
          final String tokenView = Fmt.tokenView(symbol);

          List<String> communityIds = [];
          if (store.settings.endpointIsEncointer && networkName != null) {
            if (store.settings.networkConst['communityIds'] != null) {
              communityIds.addAll(List<String>.from(store.settings.networkConst['communityIds']));
            }
            communityIds.retainWhere((i) => i != symbol);
          }
          final BalancesInfo balancesInfo = store.assets.balances[symbol];
          if (ModalRoute.of(context).isCurrent && !_dialogIsShown & store.account.cachedPin.isEmpty) {
            _dialogIsShown = true;
            WidgetsBinding.instance.addPostFrameCallback(
              (_) {
                _showPasswordDialog(context);
              },
            );
          }

          return Column(
            children: <Widget>[
              _buildTopCard(context),
              _communityCurrencyAssets(context, store),
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    BorderedTitle(
                      title: dic['gas.token'],
                    ),
                  ],
                ),
              ),
              RoundedCard(
                margin: EdgeInsets.only(top: 16),
                child: ListTile(
                  leading: Container(
                    width: 36,
                    child: Image.asset('assets/images/assets/${symbol.isNotEmpty ? symbol : 'DOT'}.png'),
                  ),
                  title: Text(tokenView),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Fmt.priceFloorBigInt(balancesInfo != null ? balancesInfo.total : BigInt.zero, decimals,
                            lengthFixed: 3),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black54),
                      ),
                      Container(width: 16),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, AssetPage.route,
                        arguments: AssetPageParams(token: symbol, isEncointerCommunityCurrency: false));
                  },
                ),
              ),
              Column(
                children: communityIds.map((i) {
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
                        Fmt.priceFloorBigInt(Fmt.balanceInt(store.assets.tokenBalances[i]), decimals, lengthFixed: 3),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black54),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, AssetPage.route,
                            arguments: AssetPageParams(token: symbol, isEncointerCommunityCurrency: false));
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _communityCurrencyAssets(BuildContext context, AppStore store) {
    final Map dic = I18n.of(context).assets;
    final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              BorderedTitle(
                title: dic['community.currency'],
              ),
            ],
          ),
        ),
        CommunityChooserPanel(store),
        Observer(builder: (_) {
          return (store.encointer.communityName != null) & (store.encointer.chosenCid != null)
              ? RoundedCard(
                  margin: EdgeInsets.only(top: 16),
                  child: ListTile(
                    key: Key('cid-asset'),
                    leading: Container(
                      width: 36,
                      child: webApi.ipfs.getCommunityIcon(store.encointer.communityIconsCid, devicePixelRatio),
                    ),
                    title: Text(store.encointer.communityName + " (${store.encointer.communitySymbol})"),
                    trailing: store.encointer.communityBalance != null
                        ? Text(
                            Fmt.doubleFormat(store.encointer.communityBalance),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black54),
                          )
                        : CupertinoActivityIndicator(),
                    onTap: store.encointer.communityBalance != null
                        ? () {
                            Navigator.pushNamed(context, AssetPage.route,
                                arguments: AssetPageParams(
                                    token: store.encointer.chosenCid,
                                    isEncointerCommunityCurrency: true,
                                    communityName: store.encointer.communityName,
                                    communitySymbol: store.encointer.communitySymbol));
                          }
                        : null,
                  ),
                )
              : Container();
        }),
        Container(
          padding: EdgeInsets.only(bottom: 32),
        ),
      ],
    );
  }
}
