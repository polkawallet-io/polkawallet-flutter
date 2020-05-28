import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/JumpToBrowserLink.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/consts/dotClaimTerms.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/page/assets/claim/util.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class AttestPage extends StatelessWidget {
  AttestPage(this.store);

  static const String route = '/assets/attest';

  final AppStore store;

  Future<void> _onSubmit(BuildContext context, String statement) async {
    final Map dic = I18n.of(context).assets;
    var args = {
      "title": dic['claim'],
      "txInfo": {
        "module": 'claims',
        "call": 'attest',
      },
      "detail": jsonEncode({
        "statement": statement,
      }),
      "params": [
        // "statement"
        statement,
      ],
      'onFinish': (BuildContext txPageContext, Map res) {
        Navigator.popUntil(txPageContext, ModalRoute.withName('/'));
        globalBalanceRefreshKey.currentState.show();
      }
    };
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).assets;
    String ethAddress = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(dic['claim']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dic['amount'],
                  style: Theme.of(context).textTheme.headline4,
                ),
                FutureBuilder(
                  future: ClaimUtil.fetchClaimAmount(webApi, ethAddress),
                  builder: (_, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data,
                        style: Theme.of(context).textTheme.headline4,
                      );
                    }
                    return CupertinoActivityIndicator();
                  },
                )
              ],
            ),
            Divider(height: 24),
            Text(
              dic['claim.terms'],
              style: Theme.of(context).textTheme.headline4,
            ),
            FutureBuilder(
              future: ClaimUtil.fetchStatementKind(webApi, ethAddress),
              builder: (_, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  bool isRegular = snapshot.data == 'Regular';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(isRegular
                            ? dot_claim_terms_regular
                            : dot_claim_terms_saft),
                      ),
                      Divider(),
                      Text(
                        dic['claim.terms.url'],
                        style: TextStyle(fontSize: 16),
                      ),
                      JumpToBrowserLink(
                        isRegular
                            ? 'https://statement.polkadot.network/regular.html'
                            : 'https://statement.polkadot.network/saft.html',
                        mainAxisAlignment: MainAxisAlignment.start,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16, bottom: 32),
                        child: RoundedButton(
                          text: dic['claim.agree'],
                          onPressed: () => _onSubmit(context,
                              ClaimUtil.getStatementSentence(snapshot.data)),
                        ),
                      )
                    ],
                  );
                }
                return CupertinoActivityIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}
