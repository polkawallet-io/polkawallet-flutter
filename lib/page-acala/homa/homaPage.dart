import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/infoItem.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/page-acala/homa/mintPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/acala/types/stakingPoolInfoData.dart';
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
    await webApi.acala.fetchHomaStakingPool();
//    await webApi.acala.fetchHomaUserUnbonding();
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
        int decimals = store.settings.networkState.tokenDecimals;

        StakingPoolInfoData pool = store.acala.stakingPoolInfo;

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
                              height: 140,
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
                                  Text('pool'),
                                  Padding(
                                    padding: EdgeInsets.only(top: 16),
                                    child: Text('total'),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 16),
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
                                        title: 'bonded',
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
                                        title: 'free',
                                        content: Fmt.doubleFormat(
                                          pool.communalFree,
                                        ),
                                      ),
                                      InfoItem(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        title: 'unbonding',
                                        content: Fmt.doubleFormat(
                                          pool.unbondingToFree,
                                        ),
                                      ),
                                      InfoItem(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        title: 'ratio',
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
                        RoundedCard(
                          margin: EdgeInsets.all(16),
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: <Widget>[Text('user')],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: RoundedButton(
                      text: dic['homa.mint'],
                      onPressed: () {
                        Navigator.of(context).pushNamed(MintPage.route);
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
