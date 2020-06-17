import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
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
                    return CupertinoActivityIndicator();
                  }
                  return ListView(
                    padding: EdgeInsets.all(16),
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          child: _AcalaCard(
                            dic['loan.title'],
                            dic['loan.brief'],
                            'assets/images/acala/loan.svg',
                          ),
                          onTap: () =>
                              Navigator.of(context).pushNamed(LoanPage.route),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          child: _AcalaCard(
                            dic['dex.title'],
                            dic['dex.brief'],
                            'assets/images/acala/exchange.svg',
                            color: Theme.of(context).primaryColor,
                          ),
                          onTap: () =>
                              Navigator.of(context).pushNamed(SwapPage.route),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          child: _AcalaCard(
                            dic['earn.title'],
                            dic['earn.brief'],
                            'assets/images/acala/deposit.svg',
                            color: Colors.blueAccent,
                          ),
                          onTap: () =>
                              Navigator.of(context).pushNamed(EarnPage.route),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          child: _AcalaCard(
                            dic['homa.title'],
                            dic['homa.brief'],
                            'assets/images/acala/swap.svg',
                            color: Theme.of(context).primaryColor,
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

class _AcalaCard extends StatelessWidget {
  _AcalaCard(this.title, this.brief, this.icon, {this.color});

  final String icon;
  final String title;
  final String brief;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RoundedCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(28),
            width: 110,
            decoration: BoxDecoration(
              color: color ?? Colors.blue,
              borderRadius: const BorderRadius.only(
                  topLeft: const Radius.circular(8),
                  bottomLeft: const Radius.circular(8)),
            ),
            child: SvgPicture.asset(
              icon,
              height: 56,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 16),
                width: MediaQuery.of(context).size.width / 2,
                child: Text(
                  brief,
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).unselectedWidgetColor),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
