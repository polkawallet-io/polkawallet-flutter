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

  bool _loading = false;

  TabController _tabController;
  int _txsPage = 0;
  bool _isLastPage = false;
  ScrollController _scrollController;

  Future<void> _updateData() async {
    if (store.settings.loading || _loading) return;
    setState(() {
      _loading = true;
    });

    webApi.assets.fetchBalance();
    Map res = {"transfers": []};

    final String symbol = store.settings.networkState.tokenSymbol;
    final String token = ModalRoute.of(context).settings.arguments;
    final bool isBaseToken = token == symbol;
    if (isBaseToken &&
        store.settings.endpoint.info != networkEndpointLaminar.info) {
      webApi.staking.fetchAccountStaking();
      res = await webApi.assets.updateTxs(_txsPage);
    }
    if (!mounted) return;
    setState(() {
      _loading = false;
    });

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
      _refreshData();
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
    final String symbol = store.settings.networkState.tokenSymbol;
    final String token = ModalRoute.of(context).settings.arguments;
    final bool isBaseToken = token == symbol;
//    final isAcala = store.settings.endpoint.info == networkEndpointAcala.info;
    final isLaminar =
        store.settings.endpoint.info == networkEndpointLaminar.info;
    if (!isBaseToken || isLaminar) {
      List<TransferData> ls = isLaminar
          ? store.laminar.txsTransfer.reversed.toList()
          : store.acala.txsTransfer.reversed.toList();
      ls.retainWhere((i) => i.token.toUpperCase() == token.toUpperCase());
      res.addAll(ls.map((i) {
        String crossChain;
        Map<String, dynamic> tx = TransferData.toJson(i);
        if (i.to == cross_chain_transfer_address_acala) {
          tx['to'] = store.account.currentAddress;
          crossChain = 'Acala';
        }
        if (i.to == cross_chain_transfer_address_laminar) {
          tx['to'] = store.account.currentAddress;
          crossChain = 'Laminar';
        }
        return TransferListItem(
          data: crossChain != null ? TransferData.fromJson(tx) : i,
          token: token,
          isOut: true,
          hasDetail: false,
          crossChain: crossChain,
        );
      }));
      res.add(ListTail(
        isEmpty: ls.length == 0,
        isLoading: false,
      ));
    } else {
      res.addAll(store.assets.txsView.map((i) {
        return TransferListItem(
          data: i,
          token: token,
          isOut: i.from == store.account.currentAddress,
          hasDetail: true,
        );
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
    final dic = I18n.of(context).assets;
    final List<Tab> _myTabs = <Tab>[
      Tab(text: dic['all']),
      Tab(text: dic['in']),
      Tab(text: dic['out']),
    ];

    final int decimals = store.settings.networkState.tokenDecimals;
    final String symbol = store.settings.networkState.tokenSymbol;
    final String token = ModalRoute.of(context).settings.arguments;
    final String tokenView = Fmt.tokenView(token);
    final bool isBaseToken = token == symbol;

    final isLaminar =
        store.settings.endpoint.info == networkEndpointLaminar.info;

    final primaryColor = Theme.of(context).primaryColor;
    final titleColor = Theme.of(context).cardColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(tokenView),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Observer(
          builder: (_) {
            BigInt balance =
                Fmt.balanceInt(store.assets.tokenBalances[token.toUpperCase()]);

            BalancesInfo balancesInfo = store.assets.balances[symbol];
            String lockedInfo = '\n';
            if (balancesInfo != null && balancesInfo.lockedBreakdown != null) {
              balancesInfo.lockedBreakdown.forEach((i) {
                if (i.amount > BigInt.zero) {
                  lockedInfo += '${Fmt.priceFloorBigInt(
                    i.amount,
                    decimals,
                    lengthMax: 3,
                  )} $tokenView ${dic['lock.${i.use}']}\n';
                }
              });
            }

            String tokenPrice;
            if ((store.settings.endpoint.info == network_name_polkadot ||
                    store.settings.endpoint.info == network_name_kusama) &&
                store.assets.marketPrices[symbol] != null &&
                balancesInfo != null) {
              tokenPrice = (store.assets.marketPrices[symbol] *
                      Fmt.bigIntToDouble(balancesInfo.total, decimals))
                  .toStringAsFixed(4);
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
                        padding: EdgeInsets.only(
                            bottom: tokenPrice != null ? 4 : 16),
                        child: Text(
                          Fmt.token(isBaseToken ? balancesInfo.total : balance,
                              decimals,
                              length: 8),
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      tokenPrice != null
                          ? Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: Text(
                                '≈ \$ ${tokenPrice ?? '--.--'}',
                                style: TextStyle(
                                  color: Theme.of(context).cardColor,
                                ),
                              ),
                            )
                          : Container(),
                      isBaseToken
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Column(
                                  children: [
                                    Text(
                                      dic['locked'],
                                      style: TextStyle(
                                          color: titleColor, fontSize: 12),
                                    ),
                                    Row(
                                      children: [
                                        lockedInfo.length > 2
                                            ? TapTooltip(
                                                message: lockedInfo,
                                                child: Padding(
                                                  padding:
                                                      EdgeInsets.only(right: 6),
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
                                          Fmt.priceFloorBigInt(
                                            balancesInfo.lockedBalance,
                                            decimals,
                                            lengthMax: 3,
                                          ),
                                          style: TextStyle(color: titleColor),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      dic['available'],
                                      style: TextStyle(
                                          color: titleColor, fontSize: 12),
                                    ),
                                    Text(
                                      Fmt.priceFloorBigInt(
                                        balancesInfo.transferable,
                                        decimals,
                                        lengthMax: 3,
                                      ),
                                      style: TextStyle(color: titleColor),
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      dic['reserved'],
                                      style: TextStyle(
                                          color: titleColor, fontSize: 12),
                                    ),
                                    Text(
                                      Fmt.priceFloorBigInt(
                                        balancesInfo.reserved,
                                        decimals,
                                        lengthMax: 3,
                                      ),
                                      style: TextStyle(color: titleColor),
                                    )
                                  ],
                                ),
                              ],
                            )
                          : Container(),
                    ],
                  ),
                ),
                isBaseToken && !isLaminar
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
                              title: I18n.of(context).acala['loan.txs'],
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
                              ),
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
  TransferListItem({
    this.data,
    this.token,
    this.isOut,
    this.hasDetail,
    this.crossChain,
  });

  final TransferData data;
  final String token;
  final String crossChain;
  final bool isOut;
  final bool hasDetail;

  @override
  Widget build(BuildContext context) {
    String address = isOut ? data.to : data.from;
    String title =
        Fmt.address(address) ?? data.extrinsicIndex ?? Fmt.address(data.hash);
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: Colors.black12)),
      ),
      child: ListTile(
        title: Text('$title${crossChain != null ? ' ($crossChain)' : ''}'),
        subtitle: Text(Fmt.dateTime(
            DateTime.fromMillisecondsSinceEpoch(data.blockTimestamp * 1000))),
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
