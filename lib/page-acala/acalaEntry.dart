import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/page-acala/exchange/exchangePage.dart';
import 'package:polka_wallet/page-acala/loan/loanPage.dart';
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
        child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.all(16),
          child: ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      dic['acala'] ?? 'Acala Platform',
                      style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).cardColor,
                          fontWeight: FontWeight.w500),
                    )
                  ],
                ),
              ),
              GestureDetector(
                child: _AcalaCard(
                  dic['loan.title'],
                  dic['loan.bref'],
                  'assets/images/acala/loan.svg',
                ),
                onTap: () => Navigator.of(context).pushNamed(LoanPage.route),
              ),
              GestureDetector(
                child: _AcalaCard(
                  dic['dex.title'],
                  dic['dex.bref'],
                  'assets/images/acala/exchange.svg',
                  color: Colors.grey,
                ),
//                onTap: () =>
//                    Navigator.of(context).pushNamed(ExchangePage.route),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AcalaCard extends StatelessWidget {
  _AcalaCard(this.title, this.bref, this.icon, {this.color});

  final String icon;
  final String title;
  final String bref;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RoundedCard(
      margin: EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(32),
            width: 140,
            decoration: BoxDecoration(
              color: color ?? Colors.blue,
              borderRadius: const BorderRadius.only(
                  topLeft: const Radius.circular(8),
                  bottomLeft: const Radius.circular(8)),
            ),
            child: SvgPicture.asset(
              icon,
              height: 100,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.display4,
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 16),
                width: MediaQuery.of(context).size.width / 2,
                child: Text(
                  bref,
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).unselectedWidgetColor),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
