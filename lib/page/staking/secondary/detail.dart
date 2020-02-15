import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/page/assets/secondary/transfer/txDetail.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class StakingDetail extends StatelessWidget {
  StakingDetail(this.store);

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).staking;
    String symbol = store.settings.networkState.tokenSymbol;
    final Map<String, dynamic> detail =
        ModalRoute.of(context).settings.arguments;
    String action = detail['attributes']['call_id'];
    List<DetailInfoItem> info = <DetailInfoItem>[
      DetailInfoItem(label: dic['action'], title: action),
    ];
    switch (action) {
      case 'bond':
        String value = Fmt.token(detail['detail']['params'][1]['value']);
        info.add(DetailInfoItem(
          label: dic['value'],
          title: '$value $symbol',
        ));
        break;
      case 'bond_extra':
      case 'unbond':
        String value = Fmt.token(detail['detail']['params'][0]['value']);
        info.add(DetailInfoItem(
          label: dic['value'],
          title: '$value $symbol',
        ));
        break;
      case 'nominate':
        List targets = detail['detail']['params'][0]['value'];
        bool isFirst = true;
        targets.forEach((i) {
          info.add(DetailInfoItem(
            label: isFirst ? dic['validators'] : '',
            title: Fmt.address(i['value']),
            address: i['value'],
          ));
          if (isFirst) {
            isFirst = false;
          }
        });
        break;
    }
    return TxDetail(
      success: detail['attributes']['success'] > 0,
      action: action,
      eventId: detail['id'],
      block: store.assets.blockMap[detail['attributes']['block_id']],
      info: info,
    );
  }
}
