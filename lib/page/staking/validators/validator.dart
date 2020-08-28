import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/page/staking/validators/validatorDetailPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/staking/types/validatorData.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class Validator extends StatelessWidget {
  Validator(
    this.validator,
    this.accInfo,
    this.decimals,
    this.nominations,
  ) : isWaiting = validator.total == BigInt.zero;

  final ValidatorData validator;
  final Map accInfo;
  final int decimals;
  final bool isWaiting;
  final List nominations;

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
                  Fmt.accountDisplayName(
                    validator.accountId,
                    accInfo,
                  ),
                  Text(
                    !isWaiting
                        ? '${dic['total']}: ${hasDetail ? Fmt.token(validator.total, decimals) : '~'}'
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
