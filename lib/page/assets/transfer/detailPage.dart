import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/page/assets/transfer/txDetail.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/assets/types/transferData.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class TransferDetailPage extends StatelessWidget {
  TransferDetailPage(this.store);

  static final String route = '/assets/tx';
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).assets;
    final String symbol = store.settings.networkState.tokenSymbol;
    final int decimals = store.settings.networkState.tokenDecimals;

    final TransferData tx = ModalRoute.of(context).settings.arguments;

    final String txType = tx.from == store.account.currentAddress
        ? dic['transfer']
        : dic['receive'];

    return TxDetail(
      success: true,
      action: txType,
      eventId: tx.extrinsicIndex,
      hash: tx.hash,
      blockTime: DateTime.fromMillisecondsSinceEpoch(tx.blockTimestamp * 1000)
          .toString(),
      blockNum: tx.blockNum,
      networkName: store.settings.endpoint.info,
      info: <DetailInfoItem>[
        DetailInfoItem(
          label: dic['value'],
          title: '${tx.amount} $symbol',
        ),
        DetailInfoItem(
          label: dic['fee'],
          title:
              '${Fmt.balance(tx.fee, decimals: decimals, length: decimals)} $symbol',
        ),
        DetailInfoItem(
          label: dic['from'],
          title: Fmt.address(tx.from),
          address: tx.from,
        ),
        DetailInfoItem(
          label: dic['to'],
          title: Fmt.address(tx.to),
          address: tx.to,
        )
      ],
    );
  }
}
