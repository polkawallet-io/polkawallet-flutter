import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/BorderedTitle.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/page/profile/recovery/initiateRecoveryPage.dart';
import 'package:polka_wallet/page/profile/recovery/recoverySettingPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/account/types/accountRecoveryInfo.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/staking/types/txData.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class RecoveryStatePage extends StatefulWidget {
  RecoveryStatePage(this.store);
  static final String route = '/profile/recovery/state';
  final AppStore store;

  @override
  _RecoveryStatePage createState() => _RecoveryStatePage();
}

class _RecoveryStatePage extends State<RecoveryStatePage> {
  final String _actionClaimRecovery = 'claim';
  final String _actionCancelRecovery = 'cancel';

  List<TxData> _txs = [];
  List<AccountRecoveryInfo> _recoverableInfoList = [];
  List _activeRecoveriesStatus = [];
  List _proxyStatus = [];
  int _currentBlock = 0;
  bool _loading = false;

  Future<void> _fetchData() async {
    webApi.assets.fetchBalance();
    Map res = await webApi.subScanApi.fetchTxsAsync(
      webApi.subScanApi.moduleRecovery,
      call: 'initiate_recovery',
      sender: widget.store.account.currentAddress,
    );
    if (res['extrinsics'] == null) return;
    List txs = List.of(res['extrinsics']);
    if (txs.length > 0) {
      List<TxData> ls = txs.map((e) => TxData.fromJson(e)).toList();
      ls.retainWhere((i) => i.success);
      List<String> pubKeys = [];
      ls.toList().forEach((i) {
        String key = '0x${List.of(jsonDecode(i.params))[0]['value']}';
        if (!pubKeys.contains(key)) {
          pubKeys.add(key);
        } else {
          ls.remove(i);
        }
      });
      await webApi.account.encodeAddress(pubKeys);

      List<String> addresses = pubKeys
          .map((e) => widget.store.account
              .pubKeyAddressMap[widget.store.settings.endpoint.ss58][e])
          .toList();

      /// fetch active recovery status
      List status = await Future.wait([
        webApi.evalJavascript('api.derive.chain.bestNumber()'),
        webApi.account.queryRecoverableList(addresses),
        webApi.account.queryActiveRecoveries(
          addresses,
          widget.store.account.currentAddress,
        ),
        webApi.account
            .queryRecoveryProxies([widget.store.account.currentAddress]),
      ]);

      List<AccountRecoveryInfo> infoList = List.of(status[1])
          .map((e) => AccountRecoveryInfo.fromJson(e))
          .toList();
      List statusList = List.of(status[2]);

      int invalidCount = 0;
      statusList.toList().asMap().forEach((k, v) {
        // recovery status is null if recovery was closed
        if (v == null) {
          print('remove $k');
          ls.removeAt(k - invalidCount);
          infoList.removeAt(k - invalidCount);
          statusList.removeAt(k - invalidCount);
          invalidCount++;
        }
      });

      setState(() {
        _txs = ls;
        _currentBlock = status[0];
        _recoverableInfoList = infoList;
        _activeRecoveriesStatus = statusList;
        _proxyStatus = status[3];
      });
    }
  }

  void _onAction(AccountRecoveryInfo info, String action) {
    final Map dic = I18n.of(context).profile;
    var args = {
      "title": dic['recovery.$action'],
      "txInfo": {
        "module": 'recovery',
        "call": action == _actionClaimRecovery
            ? 'claimRecovery'
            : 'cancelRecovered',
      },
      "detail": jsonEncode({"accountId": info.address}),
      "params": [info.address],
      'onFinish': (BuildContext txPageContext, Map res) {
        Navigator.popUntil(
            txPageContext, ModalRoute.withName('/profile/recovery/state'));
        globalRecoveryStateRefreshKey.currentState.show();
      }
    };
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalRecoveryStateRefreshKey.currentState.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).profile;

    List<List> activeList = List<List>();
    _txs.asMap().forEach((i, v) {
      bool isRecovered =
          _proxyStatus.indexOf(_recoverableInfoList[i].address) >= 0;
      activeList.add([
        v,
        _activeRecoveriesStatus[i],
        _recoverableInfoList[i],
        isRecovered,
      ]);
    });

    final int blockDuration =
        widget.store.settings.networkConst['babe']['expectedBlockTime'];

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['recovery.init']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          color: Theme.of(context).cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16, top: 16, bottom: 16),
                child: BorderedTitle(
                  title: dic['recovery.recoveries'],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchData,
                  key: globalRecoveryStateRefreshKey,
                  child: ListView(
                    children: _txs.length > 0
                        ? activeList.map((e) {
                            final int createdBlock = e[1]['created'];
                            final String start = Fmt.blockToTime(
                              _currentBlock - createdBlock,
                              blockDuration,
                            );
                            final AccountRecoveryInfo info = e[2];
                            final bool canClaim =
                                List.of(e[1]['friends']).length >=
                                        info.threshold &&
                                    (createdBlock + info.delayPeriod) <
                                        _currentBlock;
                            bool canCancel = false;
                            if (canClaim && e[3]) {
                              canCancel = true;
                            }
                            final String delay = Fmt.blockToTime(
                                info.delayPeriod, blockDuration);
                            return ActiveRecovery(
                              tx: e[0],
                              status: e[1],
                              info: info,
                              start: start,
                              delay: delay,
                              networkState: widget.store.settings.networkState,
                              isRescuer: true,
                              proxy: canCancel,
                              action: CupertinoActionSheetAction(
                                child: Text(canCancel
                                    ? dic['recovery.cancel']
                                    : dic['recovery.claim']),
                                onPressed: canClaim
                                    ? () {
                                        Navigator.of(context).pop();
                                        if (canCancel) {
                                          _onAction(
                                              info, _actionCancelRecovery);
                                        } else {
                                          _onAction(info, _actionClaimRecovery);
                                        }
                                      }
                                    : () => {},
                              ),
                            );
                          }).toList()
                        : [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(I18n.of(context).home['data.empty']),
                            )
                          ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: RoundedButton(
                  text: dic['recovery.init'],
                  onPressed: () => Navigator.of(context)
                      .pushNamed(InitiateRecoveryPage.route),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
