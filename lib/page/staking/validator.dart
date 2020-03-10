import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/staking.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class Validator extends StatelessWidget {
  Validator(this.store, this.validator);

  final AppStore store;
  final ValidatorData validator;

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).staking;
    Map accInfo = store.account.accountIndexMap[validator.accountId];
//    print(accInfo['identity']);
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: AddressIcon(address: validator.accountId),
        title: Text(accInfo != null && accInfo['identity']['display'] != null
            ? accInfo['identity']['display'].toString().toUpperCase()
            : Fmt.address(validator.accountId, pad: 6)),
        subtitle: Text('${dic['total']}: ${Fmt.token(validator.total)}'),
        trailing: Container(
          width: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(dic['commission']),
              Text(validator.commission)
            ],
          ),
        ),
        onTap: () {
          webApi.staking.queryValidatorRewards(validator.accountId);
          Navigator.of(context)
              .pushNamed('/staking/validator', arguments: validator);
        },
      ),
    );
  }
}
