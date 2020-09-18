import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/BorderedTitle.dart';
import 'package:polka_wallet/common/components/TapTooltip.dart';
import 'package:polka_wallet/common/components/listTail.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page/assets/receive/receivePage.dart';
import 'package:polka_wallet/page/assets/transfer/detailPage.dart';
import 'package:polka_wallet/page/assets/transfer/transferPage.dart';
import 'package:polka_wallet/service/subscan.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/assets/types/balancesInfo.dart';
import 'package:polka_wallet/store/assets/types/transferData.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';
import 'package:polka_wallet/utils/localStorage.dart';

class AssetPageParams {
  AssetPageParams({this.token, this.isEncointerCommunityCurrency = false});
  final String token;
  final bool isEncointerCommunityCurrency;
}

class AssetPage extends StatefulWidget {
  AssetPage(this.store);

  static final String route = '/assets/detail';

  final AppStore store;

  @override
  _AssetPageState createState() => _AssetPageState(store);
}

class _AssetPageState extends State<AssetPage>
    with SingleTickerProviderStateMixin {
  _AssetPageState(this.store);

  final AppStore store;

  TabController _tabController;
  int _txsPage = 0;
  bool _isLastPage = false;
  ScrollController _scrollController;

  Future<void> _updateData() async {
    if (store.settings.loading) return;

    String pubKey = store.account.currentAccount.pubKey;
    webApi.assets.fetchBalance(pubKey);
    Map res = {"transfers": []};

    if (store.settings.endpoint.info == networkEndpointKusama.info ||
        store.settings.endpoint.info == networkEndpointPolkadot.info) {
      webApi.staking.fetchAccountStaking(pubKey);
      res = await webApi.assets.updateTxs(_txsPage);
    }

    if (res['transfers'] == null ||
        res['transfers'].length < tx_list_page_size) {
      setState(() {
        _isLastPage = true;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _txsPage = 0;
      _isLastPage = false;
    });
    await _updateData();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        setState(() {
          if (_tabController.index == 0 && !_isLastPage) {
            _txsPage += 1;
            _updateData();
          }
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (LocalStorage.checkCacheTimeout(store.assets.cacheTxsTimestamp)) {
        globalAssetRefreshKey.currentState.show();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Widget> _buildTxList() {
    List<Widget> res = [];
    final AssetPageParams params = ModalRoute.of(context).settings.arguments;
    final String token = params.token;
    if (store.settings.endpointIsEncointer) {
      List<TransferData> ls = store.encointer.txsTransfer.reversed.toList();
      ls.retainWhere((i) => i.token.toUpperCase() == token.toUpperCase());
      res.addAll(ls.map((i) {
        return TransferListItem(
            i, token, i.from == store.account.currentAddress, false);
      }));
      res.add(ListTail(
        isEmpty: ls.length == 0,
        isLoading: false,
      ));
    } else {
      res.addAll(store.assets.txsView.map((i) {
        return TransferListItem(
            i, token, i.from == store.account.currentAddress, true);
      }));
      res.add(ListTail(
        isEmpty: store.assets.txsView.length == 0,
        isLoading: store.assets.isTxsLoading,
      ));
    }

    return res;
  }

  @override
  Widget build(BuildContext context) {
    final String symbol = store.settings.networkState.tokenSymbol;
    final AssetPageParams params = ModalRoute.of(context).settings.arguments;
    final String token = params.token;
    final bool isEncointerCommunityCurrency =
        params.isEncointerCommunityCurrency;
    final bool isBaseToken = token == symbol;

    final dic = I18n.of(context).assets;

    final List<Tab> _myTabs = <Tab>[
      Tab(text: dic['all']),
      Tab(text: dic['in']),
      Tab(text: dic['out']),
    ];

    final primaryColor = Theme.of(context).primaryColor;
    final titleColor = Theme.of(context).cardColor;
    return Scaffold(
      appBar: AppBar(
        title: isEncointerCommunityCurrency
            ? Text(Fmt.currencyIdentifier(token))
            : Text(token),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Observer(
          builder: (_) {
            int decimals = isEncointerCommunityCurrency
                ? encointerTokenDecimals
                : store.settings.networkState.tokenDecimals;

            BigInt balance = isEncointerCommunityCurrency
                ? Fmt.tokenInt(
                    store.encointer.balanceEntries[token].principal.toString(),
                    decimals: decimals)
                : Fmt.balanceInt(
                    store.assets.tokenBalances[token.toUpperCase()]);

            BalancesInfo balancesInfo = store.assets.balances[symbol];
            String lockedInfo = '\n';
            if (balancesInfo.lockedBreakdown != null) {
              balancesInfo.lockedBreakdown.forEach((i) {
                if (i.amount > BigInt.zero) {
                  lockedInfo +=
                      '${Fmt.token(i.amount, decimals: decimals)} $symbol ${dic['lock.${i.use}']}\n';
                }
              });
            }

            return Column(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  color: primaryColor,
                  padding: EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(
                          Fmt.token(isBaseToken ? balancesInfo.total : balance,
                              decimals: decimals, length: 8),
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      isBaseToken
                          ? Builder(
                              builder: (_) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(right: 12),
                                      child: Row(
                                        children: <Widget>[
                                          lockedInfo.length > 2
                                              ? TapTooltip(
                                                  message: lockedInfo,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 6),
                                                    child: Icon(
                                                      Icons.info,
                                                      size: 16,
                                                      color: titleColor,
                                                    ),
                                                  ),
                                                  waitDuration:
                                                      Duration(seconds: 0),
                                                )
                                              : Container(),
                                          Text(
                                            '${dic['locked']}: ${Fmt.token(balancesInfo.lockedBalance, decimals: decimals)}',
                                            style: TextStyle(color: titleColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(right: 12),
                                      child: Text(
                                        '${dic['available']}: ${Fmt.token(balancesInfo.transferable, decimals: decimals)}',
                                        style: TextStyle(color: titleColor),
                                      ),
                                    ),
                                    Text(
                                      '${dic['reserved']}: ${Fmt.token(balancesInfo.reserved, decimals: decimals)}',
                                      style: TextStyle(color: titleColor),
                                    ),
                                  ],
                                );
                              },
                            )
                          : Container(),
                    ],
                  ),
                ),
                !store.settings.endpointIsEncointer
                    ? TabBar(
                        labelColor: Colors.black87,
                        labelStyle: TextStyle(fontSize: 18),
                        controller: _tabController,
                        tabs: _myTabs,
                        onTap: (i) {
                          store.assets.setTxsFilter(i);
                        },
                      )
                    : Container(
                        color: titleColor,
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: <Widget>[
                            BorderedTitle(
                              title: I18n.of(context).encointer['loan.txs'],
                            )
                          ],
                        ),
                      ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: RefreshIndicator(
                      key: globalAssetRefreshKey,
                      onRefresh: _refreshData,
                      child: ListView(
                        controller: _scrollController,
                        children: _buildTxList(),
                      ),
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
                            Navigator.pushNamed(
                              context,
                              TransferPage.route,
                              arguments: TransferPageParams(
                                  redirect: AssetPage.route,
                                  symbol: token,
                                  isEncointerCommunityCurrency:
                                      isEncointerCommunityCurrency),
                            );
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
                            Navigator.pushNamed(context, ReceivePage.route);
                          },
                        ),
                      ),
                    )
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

class TransferListItem extends StatelessWidget {
  TransferListItem(this.data, this.token, this.isOut, this.hasDetail);

  final TransferData data;
  final String token;
  final bool isOut;
  final bool hasDetail;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: Colors.black12)),
      ),
      child: ListTile(
        title: Text(data.extrinsicIndex ?? Fmt.address(data.hash)),
        subtitle: Text(
            DateTime.fromMillisecondsSinceEpoch(data.blockTimestamp * 1000)
                .toString()),
        trailing: Container(
          width: 110,
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Text(
                '${data.amount} $token',
                style: Theme.of(context).textTheme.headline4,
              )),
              isOut
                  ? Image.asset('assets/images/assets/assets_up.png')
                  : Image.asset('assets/images/assets/assets_down.png')
            ],
          ),
        ),
        onTap: hasDetail
            ? () {
                Navigator.pushNamed(context, TransferDetailPage.route,
                    arguments: data);
              }
            : null,
      ),
    );
  }
}
