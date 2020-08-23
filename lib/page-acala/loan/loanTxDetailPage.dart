import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page/assets/transfer/txDetail.dart';
import 'package:polka_wallet/store/acala/types/loanType.dart';
import 'package:polka_wallet/store/acala/types/txLoanData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class LoanTxDetailPage extends StatelessWidget {
  LoanTxDetailPage(this.store);

  static final String route = '/acala/loan/tx';
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).acala;
    final int decimals = store.settings.networkState.tokenDecimals;

    final TxLoanData tx = ModalRoute.of(context).settings.arguments;
    LoanType loanType =
        store.acala.loanTypes.firstWhere((i) => i.token == tx.currencyId);
    BigInt amountView = tx.amountCollateral;
    if (tx.currencyIdView.toUpperCase() == acala_stable_coin) {
      amountView = loanType.debitShareToDebit(tx.amountDebitShare, decimals);
    }

    List<DetailInfoItem> list = <DetailInfoItem>[
      DetailInfoItem(
        label: dic['txs.action'],
        title: tx.actionType,
      ),
      DetailInfoItem(
        label: dic['loan.amount'],
        title:
            '${Fmt.priceFloorBigInt(amountView, decimals)} ${tx.currencyIdView}',
      ),
    ];
    if (tx.actionType == 'create') {
      print(tx.amountCollateral);
      list.add(DetailInfoItem(
        label: '',
        title:
            '${Fmt.priceFloorBigInt(tx.amountCollateral, decimals)} ${tx.currencyId}',
      ));
    }
    return TxDetail(
      success: true,
      action: '',
      eventId: 'tx.id',
      hash: tx.hash,
      networkName: store.settings.endpoint.info,
      info: list,
    );
  }
}
