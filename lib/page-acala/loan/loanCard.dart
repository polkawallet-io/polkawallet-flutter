import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/infoItem.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page-acala/loan/loanAdjustPage.dart';
import 'package:polka_wallet/store/acala/acala.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class LoanCard extends StatelessWidget {
  LoanCard(this.loan, this.balance);
  final LoanData loan;
  final String balance;
  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).acala;

    String collateral =
        Fmt.token(loan.collaterals, decimals: acala_token_decimals);
    String collateralRequired =
        Fmt.token(loan.requiredCollateral, decimals: acala_token_decimals);

    Color primaryColor = Theme.of(context).primaryColor;
    return RoundedCard(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
      child: Column(
        children: <Widget>[
          Text(dic['loan.borrowed'] + ' aUSD'),
          Padding(
            padding: EdgeInsets.only(top: 8, bottom: 0),
            child: Text(
              Fmt.token(loan.debits, decimals: acala_token_decimals),
              style: TextStyle(
                fontSize: 36,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              '${I18n.of(context).assets['balance']}: $balance',
              style: TextStyle(fontSize: 14),
            ),
          ),
          Divider(height: 32),
          Row(
            children: <Widget>[
              InfoItem(
                title: '${dic['loan.collateral']}/${dic['collateral.require']}',
                content: '$collateral/$collateralRequired ${loan.token}',
              ),
              Container(
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
                          style: TextStyle(color: primaryColor),
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
                          style: TextStyle(color: primaryColor),
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
