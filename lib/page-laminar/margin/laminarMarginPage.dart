import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page-laminar/margin/laminarMarginTradePairSelector.dart';
import 'package:polka_wallet/page-laminar/margin/laminarMarginTradePanel.dart';
import 'package:polka_wallet/page-laminar/margin/laminarMarginTraderInfoPanel.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/laminar/types/laminarMarginData.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class LaminarMarginPage extends StatefulWidget {
  LaminarMarginPage(this.store, {this.child, this.onRefresh});

  static const String route = '/laminar/margin';
  final AppStore store;
  final Widget child;
  final Function onRefresh;

  @override
  _LaminarMarginPageState createState() => _LaminarMarginPageState();
}

class _LaminarMarginPageState extends State<LaminarMarginPage> {
  String _poolId = '1';
  String _pairId = 'BTCUSD';

  int _leverageIndex = 0;

  Future<void> _fetchData() async {
    webApi.assets.fetchBalance();
    widget.onRefresh();
    await webApi.laminar.subscribeMarginTraderInfo();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      webApi.laminar.subscribeMarginPools();
      globalMarginRefreshKey.currentState.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).laminar;
    final int decimals = widget.store.settings.networkState.tokenDecimals;
    return Scaffold(
      appBar: AppBar(title: Text(dic['flow.margin']), centerTitle: true),
      body: SafeArea(
        child: Observer(
          builder: (_) {
            final String balance = Fmt.balance(
              widget.store.laminar.marginPoolInfo[_poolId]?.balance ?? '0',
              decimals,
            );
            final LaminarMarginPoolInfoData poolInfo =
                widget.store.laminar.marginPoolInfo[_poolId];

            return RefreshIndicator(
              key: globalMarginRefreshKey,
              onRefresh: _fetchData,
              child: Container(
                color: Theme.of(context).cardColor,
                child: ListView(
                  children: <Widget>[
                    ListTile(
                      title: Text(_pairId),
                      subtitle: Text(
                        '${margin_pool_name_map[_poolId]} $balance aUSD',
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (_) => LaminarMarginTradePairSelector(
                            widget.store,
                            initialPoolId: _poolId,
                            initialPairId: _pairId,
                            onSelect: (pool, pair) {
                              setState(() {
                                _poolId = pool;
                                _pairId = pair;
                                _leverageIndex = 0;
                              });
                            },
                          ),
                        );
                      },
                    ),
                    Divider(height: 2),
                    LaminarTraderInfoPanel(
                      balanceInt: Fmt.balanceInt(
                          widget.store.assets.tokenBalances[acala_stable_coin]),
                      info: widget.store.laminar.marginTraderInfo[_poolId],
                      decimals: decimals,
                    ),
                    poolInfo != null
                        ? LaminarMarginTradePanel(
                            info:
                                widget.store.laminar.marginTraderInfo[_poolId],
                            decimals: decimals,
                            pairData: widget
                                .store.laminar.marginPoolInfo[_poolId].options
                                .firstWhere((e) {
                              return e.pairId == _pairId;
                            }),
                            priceMap: widget.store.laminar.tokenPrices,
                            leverageIndex: _leverageIndex,
                            onLeverageChange: (int i) {
                              setState(() {
                                _leverageIndex = i;
                              });
                            })
                        : Container(),
                    Divider(height: 2),
                    widget.child,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
