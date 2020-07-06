import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/BorderedTitle.dart';
import 'package:polka_wallet/common/components/TxList.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/page/profile/recovery/vouchRecoveryPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/staking/types/txData.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class RecoveryProofPage extends StatefulWidget {
  RecoveryProofPage(this.store);
  static final String route = '/profile/recovery/proof';
  final AppStore store;

  @override
  _RecoveryStatePage createState() => _RecoveryStatePage();
}

class _RecoveryStatePage extends State<RecoveryProofPage> {
  List<TxData> _txs = [];
  bool _loading = false;

  Future<void> _fetchData() async {
    Map res = await webApi.subScanApi.fetchTxsAsync(
      webApi.subScanApi.moduleRecovery,
      call: 'vouch_recovery',
      sender: widget.store.account.currentAddress,
    );
    if (res['extrinsics'] == null) return;
    List txs = List.of(res['extrinsics']);
    if (txs.length > 0) {
      List<TxData> ls = txs.map((e) => TxData.fromJson(e)).toList();
      List<String> pubKeys = [];
      ls.forEach((i) {
        pubKeys.addAll(List.of(jsonDecode(i.params)).map((e) => e['value']));
      });
      webApi.account.encodeAddress(pubKeys);
      setState(() {
        _txs = ls;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalRecoveryProofRefreshKey.currentState.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).profile;

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['recovery.help']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          color: Theme.of(context).cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16, top: 16),
                child: BorderedTitle(
                  title: dic['recovery.history'],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchData,
                  key: globalRecoveryProofRefreshKey,
                  child: _txs.length > 0
                      ? TxList(_txs)
                      : ListView(
                          children: [
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
                  text: dic['recovery.help'],
                  onPressed: () =>
                      Navigator.of(context).pushNamed(VouchRecoveryPage.route),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
