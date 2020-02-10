import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/page/assets/secondary/asset/assetChart.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/store/assets.dart';
import 'package:polka_wallet/store/settings.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class AssetPage extends StatefulWidget {
  AssetPage(this.accountStore, this.settingsStore);

  final AccountStore accountStore;
  final SettingsStore settingsStore;

  @override
  _AssetPageState createState() => _AssetPageState(accountStore, settingsStore);
}

class _AssetPageState extends State<AssetPage>
    with SingleTickerProviderStateMixin {
  _AssetPageState(this.accountStore, this.settingsStore);

  final AccountStore accountStore;
  final SettingsStore settingsStore;

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Widget> _buildTxList(BuildContext context) {
    if (accountStore.assetsState.txsView.length == 0) {
      return [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No Data',
                style: TextStyle(fontSize: 18, color: Colors.black38),
              ),
            )
          ],
        )
      ];
    }
    int decimals = settingsStore.networkState.tokenDecimals;
    String symbol = settingsStore.networkState.tokenSymbol;
    Map<int, BlockData> blockMap = accountStore.assetsState.blockMap;
    return accountStore.assetsState.txsView.map((i) {
      BlockData block = blockMap[i.block];
      String time = 'time';
      if (block != null) {
        time = block.time.toString().split('.')[0];
      }
      return Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 0.5, color: Colors.black12)),
        ),
        child: ListTile(
            title: Text(i.id),
            subtitle: Text(time),
            trailing: Container(
              width: 110,
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: Text(
                    '${Fmt.token(i.value, decimals)} $symbol',
                    style: Theme.of(context).textTheme.display4,
                  )),
                  i.sender == accountStore.currentAccount.address
                      ? Image.asset('assets/images/assets/assets_up.png')
                      : Image.asset('assets/images/assets/assets_down.png')
                ],
              ),
            ),
            onTap: () {
              accountStore.assetsState.setTxDetail(i);
              Navigator.pushNamed(context, '/assets/tx');
            }),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) => Observer(
        builder: (_) {
          final Map<String, String> dic = I18n.of(context).assets;
          final List<Tab> _myTabs = <Tab>[
            Tab(text: dic['all']),
            Tab(text: dic['in']),
            Tab(text: dic['out']),
          ];

          String balance = Fmt.balance(accountStore.assetsState.balance);

          List<Map<String, dynamic>> balanceHistory =
              accountStore.assetsState.balanceHistory;
          return Scaffold(
            appBar: AppBar(
              title: Text(settingsStore.networkState.tokenSymbol),
              centerTitle: true,
            ),
            body: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: ListView(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('${dic['balance']}: $balance'),
                        ),
                        Container(
                          height: 240,
                          child: AssetChart.withData(balanceHistory),
                        ),
                        TabBar(
                          labelColor: Colors.black87,
                          labelStyle: TextStyle(fontSize: 18),
                          controller: _tabController,
                          tabs: _myTabs,
                          onTap: (i) {
                            accountStore.assetsState.setTxsFilter(i);
                          },
                        ),
                        if (accountStore.assetsState.loading)
                          Padding(
                              padding: EdgeInsets.only(top: 36),
                              child: CupertinoActivityIndicator()),
                        if (!accountStore.assetsState.loading)
                          ..._buildTxList(context)
                      ],
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        color: Colors.lightBlue,
                        child: FlatButton(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: Image.asset(
                                    'assets/images/assets/assets_send.png'),
                              ),
                              Text(
                                I18n.of(context).assets['transfer'],
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/assets/transfer');
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.lightGreen,
                        child: FlatButton(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: Image.asset(
                                    'assets/images/assets/assets_receive.png'),
                              ),
                              Text(
                                I18n.of(context).assets['receive'],
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/assets/receive');
                          },
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        },
      );
}
