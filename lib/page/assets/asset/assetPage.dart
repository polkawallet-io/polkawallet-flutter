import 'package:encointer_wallet/common/components/BorderedTitle.dart';
import 'package:encointer_wallet/common/components/TapTooltip.dart';
import 'package:encointer_wallet/common/components/listTail.dart';
import 'package:encointer_wallet/config/consts.dart';
import 'package:encointer_wallet/page/assets/receive/receivePage.dart';
import 'package:encointer_wallet/page/assets/transfer/detailPage.dart';
import 'package:encointer_wallet/page/assets/transfer/transferPage.dart';
import 'package:encointer_wallet/service/subscan.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/store/assets/types/balancesInfo.dart';
import 'package:encointer_wallet/store/assets/types/transferData.dart';
import 'package:encointer_wallet/utils/UI.dart';
import 'package:encointer_wallet/utils/format.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class AssetPageParams {
  AssetPageParams(
      {@required this.token, @required this.isEncointerCommunityCurrency, this.communityName, this.communitySymbol});

  /// token equals cid if `isEncointerCommunityCurrency == true`
  final String token;
  final bool isEncointerCommunityCurrency;
  final String communityName;
  final String communitySymbol;
}

class AssetPage extends StatefulWidget {
  AssetPage(this.store);

  static final String route = '/assets/detail';

  final AppStore store;

  @override
  _AssetPageState createState() => _AssetPageState(store);
}

class _AssetPageState extends State<AssetPage> with SingleTickerProviderStateMixin {
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

    res = await webApi.assets.updateTxs(_txsPage);

    if (!mounted) return;
    setState(() {
      _loading = false;
    });

    if (res['transfers'] == null || res['transfers'].length < tx_list_page_size) {
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
    webApi.encointer.getEncointerBalance();

    _tabController = TabController(vsync: this, length: 3);

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
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

  /// Note: Tx list display is currently limited to tx's that were sent on the running device, see:
  /// https://github.com/encointer/encointer-wallet-flutter/issues/54
  List<Widget> _buildTxList() {
    List<Widget> res = [];
    final AssetPageParams params = ModalRoute.of(context).settings.arguments;
    final String token = params.token;
    List<TransferData> ls = store.encointer.txsTransfer.reversed.toList();
    final String symbol = store.settings.networkState.tokenSymbol;
    ls.retainWhere(
        (i) => i.token.toUpperCase() == token.toUpperCase() && i.concernsCurrentAccount(store.account.currentAddress));
    res.addAll(ls.map((i) {
      return TransferListItem(
        data: i,
        token: token == symbol ? token : "",
        isOut: i.from == store.account.currentAddress,
        hasDetail: false,
      );
    }));
    res.add(ListTail(
      isEmpty: ls.length == 0,
      isLoading: false,
    ));
    return res;
  }

  @override
  Widget build(BuildContext context) {
    final AssetPageParams params = ModalRoute.of(context).settings.arguments;
    final bool isEncointerCommunityCurrency = params.isEncointerCommunityCurrency;
    final String token = params.token;

    final dic = I18n.of(context).assets;

    final String symbol = store.settings.networkState.tokenSymbol;
    final String tokenView = Fmt.tokenView(token);

    final primaryColor = Theme.of(context).primaryColor;
    final titleColor = Theme.of(context).cardColor;

    return Scaffold(
      appBar: AppBar(
        title: isEncointerCommunityCurrency ? Text(params.communitySymbol) : Text(tokenView),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Observer(
          builder: (_) {
            int decimals = isEncointerCommunityCurrency
                ? encointer_currencies_decimals
                : store.settings.networkState.tokenDecimals ?? ert_decimals;

            BigInt balance = isEncointerCommunityCurrency
                ? Fmt.tokenInt(store.encointer.communityBalance.toString(), decimals)
                : Fmt.balanceInt(store.assets.tokenBalances[token.toUpperCase()]);

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

            // Todo: Token price not available on encointer network. Subject to change?
            String tokenPrice;

            return Column(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  color: primaryColor,
                  padding: EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: tokenPrice != null ? 4 : 16),
                        child: Text(
                          Fmt.token(!isEncointerCommunityCurrency ? balancesInfo.total : balance, decimals, length: 8),
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
                      !isEncointerCommunityCurrency
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Column(
                                  children: [
                                    Text(
                                      dic['locked'],
                                      style: TextStyle(color: titleColor, fontSize: 12),
                                    ),
                                    Row(
                                      children: [
                                        lockedInfo.length > 2
                                            ? TapTooltip(
                                                message: lockedInfo,
                                                child: Padding(
                                                  padding: EdgeInsets.only(right: 6),
                                                  child: Icon(
                                                    Icons.info,
                                                    size: 16,
                                                    color: titleColor,
                                                  ),
                                                ),
                                                waitDuration: Duration(seconds: 0),
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
                                      style: TextStyle(color: titleColor, fontSize: 12),
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
                                      style: TextStyle(color: titleColor, fontSize: 12),
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
                Container(
                  color: titleColor,
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: <Widget>[BorderedTitle(title: I18n.of(context).encointer['loan.txs'])],
                  ),
                ),
                store.encointer.txsTransfer.isNotEmpty
                    ? Container(
                        color: titleColor,
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("From/To", style: Theme.of(context).textTheme.headline4),
                            Text("Amount", style: Theme.of(context).textTheme.headline4),
                          ],
                        ),
                      )
                    : Container(),
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
                        key: Key('transfer'),
                        color: Colors.lightBlue,
                        child: TextButton(
                          style: TextButton.styleFrom(padding: EdgeInsets.all(16)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: Image.asset('assets/images/assets/assets_send.png'),
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
                                  isEncointerCommunityCurrency: isEncointerCommunityCurrency,
                                  communitySymbol: params.communitySymbol),
                            );
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.lightGreen,
                        child: TextButton(
                          style: TextButton.styleFrom(padding: EdgeInsets.all(16)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: Image.asset('assets/images/assets/assets_receive.png'),
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
    String title = Fmt.address(address) ?? data.extrinsicIndex ?? Fmt.address(data.hash);
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: Colors.black12)),
      ),
      child: ListTile(
        title: Text('$title${crossChain != null ? ' ($crossChain)' : ''}'),
        subtitle: Text(Fmt.dateTime(DateTime.fromMillisecondsSinceEpoch(data.blockTimestamp * 1000))),
        trailing: Container(
          width: 110,
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Text(
                '${data.amount} $token',
                style: Theme.of(context).textTheme.headline4,
                textAlign: TextAlign.end,
              )),
              isOut
                  ? Image.asset('assets/images/assets/assets_up.png')
                  : Image.asset('assets/images/assets/assets_down.png')
            ],
          ),
        ),
        onTap: hasDetail
            ? () {
                Navigator.pushNamed(context, TransferDetailPage.route, arguments: data);
              }
            : null,
      ),
    );
  }
}
