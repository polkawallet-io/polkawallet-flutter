import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/infoItem.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page-acala/loan/loanAdjustPage.dart';
import 'package:polka_wallet/store/acala/types/loanType.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

// TODO: account balance display with address
class LoanCard extends StatelessWidget {
  LoanCard(this.loan, this.balance, this.decimals);
  final LoanData loan;
  final String balance;
  final int decimals;
  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).acala;

    String collateral = Fmt.token(loan.collaterals, decimals);
    String collateralRequired = Fmt.token(loan.requiredCollateral, decimals);
    double dailyInterest =
        Fmt.bigIntToDouble(loan.debits, decimals) * loan.stableFeeDay;
    String ratio = Fmt.ratio(loan.stableFeeYear);

    Color primaryColor = Theme.of(context).primaryColor;
    return RoundedCard(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        children: <Widget>[
          Column(
            children: <Widget>[
              Text(dic['loan.borrowed'] + ' aUSD'),
              Padding(
                padding: EdgeInsets.only(top: 8, bottom: 0),
                child: Text(
                  Fmt.priceCeilBigInt(loan.debits, decimals),
                  style: TextStyle(
                    fontSize: 36,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  '${I18n.of(context).assets['balance']}: $balance',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              Row(
                children: <Widget>[
                  InfoItem(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    title: dic['collateral.interest'],
                    content: Fmt.ratio(dailyInterest, needSymbol: false),
                  ),
                  InfoItem(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    title: dic['collateral.ratio.year'],
                    content: ratio,
                  )
                ],
              ),
            ],
          ),
          Divider(height: 32),
          Row(
            children: <Widget>[
              InfoItem(
                title: dic['loan.collateral'],
                content: collateral,
              ),
              InfoItem(
                title: dic['collateral.require'],
                content: collateralRequired,
              ),
              Container(
                margin: EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: primaryColor),
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                        child: Text(
                          dic['loan.deposit'],
                          style: TextStyle(color: primaryColor, fontSize: 13),
                        ),
                      ),
                      onTap: () => Navigator.of(context).pushNamed(
                        LoanAdjustPage.route,
                        arguments: LoanAdjustPageParams(
                            LoanAdjustPage.actionTypeDeposit, loan.token),
                      ),
                    ),
                    GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(left: BorderSide(color: primaryColor)),
                        ),
                        padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                        child: Text(
                          dic['loan.withdraw'],
                          style: TextStyle(color: primaryColor, fontSize: 13),
                        ),
                      ),
                      onTap: () => Navigator.of(context).pushNamed(
                        LoanAdjustPage.route,
                        arguments: LoanAdjustPageParams(
                            LoanAdjustPage.actionTypeWithdraw, loan.token),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
