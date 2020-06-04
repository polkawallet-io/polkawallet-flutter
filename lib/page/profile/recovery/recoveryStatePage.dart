import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/BorderedTitle.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/page/profile/recovery/initiateRecoveryPage.dart';
import 'package:polka_wallet/service/subscan.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class RecoveryStatePage extends StatefulWidget {
  RecoveryStatePage(this.store);
  static final String route = '/profile/recovery/state';
  final AppStore store;

  @override
  _RecoveryStatePage createState() => _RecoveryStatePage();
}

class _RecoveryStatePage extends State<RecoveryStatePage> {
  List _txs = [];
  bool _loading = false;

  Future<void> _fetchData() async {
    Map res = await SubScanApi.fetchTxs(
      SubScanApi.module_Recovery,
      call: 'initiate_recovery',
      sender: widget.store.account.currentAddress,
    );
    if (res['extrinsics'] == null) return;
    List txs = List.of(res['extrinsics']);
    print('_activeRecoveries');
    print(txs);
    if (txs.length > 0) {
      setState(() {
        _txs = txs;
      });
    }
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

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['recovery.init']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          color: Theme.of(context).cardColor,
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchData,
                  key: globalRecoveryStateRefreshKey,
                  child: ListView(
                    padding: EdgeInsets.all(16),
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: BorderedTitle(
                          title: dic['recovery.history'],
                        ),
                      ),
                      _txs.length > 0
                          ? Column(
                              children: _txs.map((e) {
                                return ListTile(
                                  title: Text('address'),
                                  subtitle: Text('time'),
                                  trailing: Container(
                                    child: Column(
                                      children: [
                                        Text('status'),
                                        Text('time left'),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            )
                          : Text(I18n.of(context).home['data.empty'])
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
