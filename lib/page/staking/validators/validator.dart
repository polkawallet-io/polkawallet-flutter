import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/page/staking/validators/validatorDetailPage.dart';
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
    List judgements = accInfo['identity']['judgements'];
    return GestureDetector(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: AddressIcon(address: validator.accountId),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      judgements.length > 0
                          ? Container(
                              width: 14,
                              margin: EdgeInsets.only(right: 4),
                              child: Image.asset(
                                  'assets/images/assets/success.png'),
                            )
                          : Container(),
                      Text(accInfo != null &&
                              accInfo['identity']['display'] != null
                          ? accInfo['identity']['display']
                              .toString()
                              .toUpperCase()
                          : Fmt.address(validator.accountId, pad: 6)),
                    ],
                  ),
                  Text(
                    '${dic['total']}: ${Fmt.token(validator.total)}',
                    style: TextStyle(
                      color: Theme.of(context).unselectedWidgetColor,
                      fontSize: 12,
                    ),
                  ),
                  Text('${dic['commission']}: ${validator.commission}',
                      style: TextStyle(
                        color: Theme.of(context).unselectedWidgetColor,
                        fontSize: 12,
                      ))
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(dic['points']),
                Text(validator.points.toString())
              ],
            )
          ],
        ),
      ),
      onTap: () {
        webApi.staking.queryValidatorRewards(validator.accountId);
        Navigator.of(context)
            .pushNamed(ValidatorDetailPage.route, arguments: validator);
      },
    );
  }
}
