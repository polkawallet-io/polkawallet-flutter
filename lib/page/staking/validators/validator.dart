import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/textTag.dart';
import 'package:polka_wallet/page/staking/validators/validatorDetailPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/staking/types/validatorData.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class Validator extends StatelessWidget {
  Validator(
    this.validator,
    this.accInfo,
    this.nominations, {
    this.hasPhalaAirdrop = false,
  }) : isWaiting = validator.total == BigInt.zero;

  final ValidatorData validator;
  final Map accInfo;
  final bool isWaiting;
  final List nominations;
  final bool hasPhalaAirdrop;

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).staking;
//    print(accInfo['identity']);
    bool hasDetail = validator.commission.isNotEmpty;
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
                      hasPhalaAirdrop ? TextTag(dic['phala']) : Container(),
                      Expanded(
                        child:
                            Text(Fmt.validatorDisplayName(validator, accInfo)),
                      ),
                    ],
                  ),
                  Text(
                    !isWaiting
                        ? '${dic['total']}: ${hasDetail ? Fmt.token(validator.total) : '~'}'
                        : '${dic['nominators']}: ${nominations.length}',
                    style: TextStyle(
                      color: Theme.of(context).unselectedWidgetColor,
                      fontSize: 12,
                    ),
                  ),
                  !isWaiting
                      ? Text(
                          '${dic['commission']}: ${hasDetail ? validator.commission : '~'}',
                          style: TextStyle(
                            color: Theme.of(context).unselectedWidgetColor,
                            fontSize: 12,
                          ),
                        )
                      : Container()
                ],
              ),
            ),
            !isWaiting
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(dic['points']),
                      Text(hasDetail ? validator.points.toString() : '~'),
                    ],
                  )
                : Container()
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
