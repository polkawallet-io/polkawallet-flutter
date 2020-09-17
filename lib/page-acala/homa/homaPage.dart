import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/infoItem.dart';
import 'package:polka_wallet/common/components/outlinedButtonSmall.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/page-acala/homa/mintPage.dart';
import 'package:polka_wallet/page-acala/homa/redeemPage.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/acala/types/stakingPoolInfoData.dart';
import 'package:polka_wallet/store/acala/types/txHomaData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class HomaPage extends StatefulWidget {
  HomaPage(this.store);

  static const String route = '/acala/homa';
  final AppStore store;

  @override
  _HomaPageState createState() => _HomaPageState(store);
}

class _HomaPageState extends State<HomaPage> {
  _HomaPageState(this.store);

  final AppStore store;

  Future<void> _refreshData() async {
    webApi.acala.fetchTokens(store.account.currentAccount.pubKey);
    webApi.acala.fetchHomaUserInfo();
    await webApi.acala.fetchHomaStakingPool();
  }

  void _onSubmitWithdraw() {
    final int decimals = store.settings.networkState.tokenDecimals;
    final HomaUserInfoData userInfo = store.acala.homaUserInfo;
    final String receive =
        Fmt.priceFloorBigInt(userInfo.unbonded, decimals, lengthMax: 3);
    var args = {
      "title": I18n.of(context).acala['homa.redeem'],
      "txInfo": {
        "module": 'homa',
        "call": 'withdrawRedemption',
      },
      "detail": jsonEncode({
        "amountReceive": receive,
      }),
      "params": [],
      "onFinish": (BuildContext txPageContext, Map res) {
//          print(res);
        res['action'] = TxHomaData.actionWithdrawRedemption;
        res['amountReceive'] = receive;
        store.acala.setHomaTxs([res]);
        Navigator.popUntil(txPageContext, ModalRoute.withName(HomaPage.route));
        globalHomaRefreshKey.currentState.show();
      }
    };
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalHomaRefreshKey.currentState.show();
    });
  }

  @override
  Widget build(_) {
    return Observer(
      builder: (BuildContext context) {
        final Map dic = I18n.of(context).acala;
        final int decimals = store.settings.networkState.tokenDecimals;

        StakingPoolInfoData pool = store.acala.stakingPoolInfo;
        HomaUserInfoData userInfo = store.acala.homaUserInfo;
        bool hasUserInfo = false;
        if (userInfo != null &&
            userInfo.unbonded != null &&
            (userInfo.unbonded > BigInt.zero || userInfo.claims.length > 0)) {
          hasUserInfo = true;
        }

        Color primary = Theme.of(context).primaryColor;
        Color white = Theme.of(context).cardColor;
        Color grey = Theme.of(context).unselectedWidgetColor;
        Color lightGrey = Theme.of(context).dividerColor;

        return Scaffold(
          appBar: AppBar(
            title: Text(dic['homa.title']),
            centerTitle: true,
            elevation: 0.0,
          ),
          body: SafeArea(
            child: RefreshIndicator(
              key: globalHomaRefreshKey,
              onRefresh: _refreshData,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView(
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 180,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [primary, white],
                                stops: [0.4, 0.9],
                              )),
                            ),
                            RoundedCard(
                              margin: EdgeInsets.all(16),
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: <Widget>[
                                  Text('DOT ${dic['homa.pool']}'),
                                  Padding(
                                    padding: EdgeInsets.only(top: 16),
                                    child: Text(
                                      dic['homa.pool.total'],
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      Fmt.doubleFormat(pool.communalTotal),
                                      style: TextStyle(
                                        color: primary,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      InfoItem(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        title: dic['homa.pool.bonded'],
                                        content: Fmt.doubleFormat(
                                          pool.communalBonded,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(height: 24),
                                  Row(
                                    children: <Widget>[
                                      InfoItem(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        title: dic['homa.pool.free'],
                                        content: Fmt.doubleFormat(
                                          pool.communalFree,
                                        ),
                                      ),
                                      InfoItem(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        title: dic['homa.pool.unbonding'],
                                        content: Fmt.doubleFormat(
                                          pool.unbondingToFree,
                                        ),
                                      ),
                                      InfoItem(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        title: dic['homa.pool.ratio'],
                                        content: Fmt.ratio(
                                          pool.communalBondedRatio,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        hasUserInfo
                            ? RoundedCard(
                                margin: EdgeInsets.all(16),
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 16),
                                      child: Text(dic['homa.user']),
                                    ),
                                    userInfo.claims.length > 0
                                        ? Column(
                                            children: userInfo.claims.map((i) {
                                              String unlockTime = (i.era -
                                                      (pool.currentEra ?? 0))
                                                  .toInt()
                                                  .toString();
                                              return Padding(
                                                padding:
                                                    EdgeInsets.only(bottom: 8),
                                                child: Row(
                                                  children: <Widget>[
                                                    InfoItem(
                                                      title: I18n.of(context)
                                                          .assets['amount'],
                                                      content:
                                                          Fmt.priceFloorBigInt(
                                                              i.claimed,
                                                              decimals),
                                                    ),
                                                    InfoItem(
                                                      title:
                                                          dic['homa.user.time'],
                                                      content:
                                                          '$unlockTime Era ≈ $unlockTime ${dic['homa.redeem.day']}',
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          )
                                        : Container(),
                                    userInfo.unbonded > BigInt.zero
                                        ? Divider(height: 24)
                                        : Container(),
                                    userInfo.unbonded > BigInt.zero
                                        ? Row(
                                            children: <Widget>[
                                              InfoItem(
                                                title:
                                                    dic['homa.user.redeemable'],
                                                content: Fmt.priceFloorBigInt(
                                                    userInfo.unbonded,
                                                    decimals),
                                              ),
                                              OutlinedButtonSmall(
                                                margin: EdgeInsets.all(0),
                                                active: true,
                                                content: dic['homa.now'],
                                                onPressed: _onSubmitWithdraw,
                                              ),
                                            ],
                                          )
                                        : Container()
                                  ],
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  pool.communalTotal != null
                      ? Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                color: Colors.blue,
                                child: FlatButton(
                                  padding: EdgeInsets.only(top: 16, bottom: 16),
                                  child: Text(
                                    dic['homa.mint'],
                                    style: TextStyle(color: white),
                                  ),
                                  onPressed: pool.communalTotal != null
                                      ? () => Navigator.of(context)
                                          .pushNamed(MintPage.route)
                                      : null,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                color: primary,
                                child: FlatButton(
                                  padding: EdgeInsets.only(top: 16, bottom: 16),
                                  child: Text(
                                    dic['homa.redeem'],
                                    style: TextStyle(color: white),
                                  ),
                                  onPressed: pool.communalTotal != null
                                      ? () => Navigator.of(context)
                                          .pushNamed(HomaRedeemPage.route)
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
