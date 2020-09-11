import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:polka_wallet/common/components/entryPageCard.dart';
import 'package:polka_wallet/page-acala/earn/earnPage.dart';
import 'package:polka_wallet/page-acala/homa/homaPage.dart';
import 'package:polka_wallet/page-acala/loan/loanPage.dart';
import 'package:polka_wallet/page-acala/swap/swapPage.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class AcalaEntry extends StatelessWidget {
  AcalaEntry(this.store);

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).acala;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    dic['acala'] ?? 'Acala Platform',
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).cardColor,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Observer(
                builder: (_) {
                  if (store.settings.loading) {
                    return Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width / 2),
                      child: Column(
                        children: [
                          CupertinoActivityIndicator(),
                          Text(I18n.of(context).assets['node.connecting']),
                        ],
                      ),
                    );
                  }
                  return ListView(
                    padding: EdgeInsets.all(16),
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          child: EntryPageCard(
                            dic['loan.title'],
                            dic['loan.brief'],
                            SvgPicture.asset(
                              'assets/images/acala/loan.svg',
                              height: 56,
                            ),
                          ),
                          onTap: () =>
                              Navigator.of(context).pushNamed(LoanPage.route),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          child: EntryPageCard(
                            dic['dex.title'],
                            dic['dex.brief'],
                            SvgPicture.asset(
                              'assets/images/acala/exchange.svg',
                              height: 56,
                            ),
                          ),
                          onTap: () =>
                              Navigator.of(context).pushNamed(SwapPage.route),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          child: EntryPageCard(
                            dic['earn.title'],
                            dic['earn.brief'],
                            SvgPicture.asset(
                              'assets/images/acala/deposit.svg',
                              height: 56,
                            ),
                          ),
                          onTap: () =>
                              Navigator.of(context).pushNamed(EarnPage.route),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          child: EntryPageCard(
                            dic['homa.title'],
                            dic['homa.brief'],
                            SvgPicture.asset(
                              'assets/images/acala/swap.svg',
                              height: 56,
                            ),
                          ),
                          onTap: () =>
                              Navigator.of(context).pushNamed(HomaPage.route),
                        ),
                      ),
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
