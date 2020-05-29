import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/page/staking/validators/validatorDetailPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/staking/types/validatorData.dart';
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
    bool hasDetail = validator.commission.isNotEmpty;

    bool hasPhalaAirdrop =
        store.staking.phalaAirdropWhiteList[validator.accountId] ?? false;
    return GestureDetector(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: AddressIcon(validator.accountId),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      accInfo != null &&
                              accInfo['identity']['judgements'].length > 0
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
                      hasPhalaAirdrop
                          ? Container(
                              child: Text(
                                dic['phala'],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).cardColor,
                                ),
                              ),
                              margin: EdgeInsets.only(left: 4),
                              padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                  Text(
                    '${dic['total']}: ${hasDetail ? Fmt.token(validator.total) : '~'}',
                    style: TextStyle(
                      color: Theme.of(context).unselectedWidgetColor,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                      '${dic['commission']}: ${hasDetail ? validator.commission : '~'}',
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
                Text(hasDetail ? validator.points.toString() : '~'),
              ],
            )
          ],
        ),
      ),
      onTap: hasDetail
          ? () {
              webApi.staking.queryValidatorRewards(validator.accountId);
              Navigator.of(context)
                  .pushNamed(ValidatorDetailPage.route, arguments: validator);
            }
          : null,
    );
  }
}
