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
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class ClaimPage extends StatefulWidget {
  ClaimPage(this.store);
  static const String route = '/assets/claim';

  final AppStore store;

  @override
  _ClaimPageState createState() => _ClaimPageState();
}

class _ClaimPageState extends State<ClaimPage> {
  final TextEditingController _addressCtrl = new TextEditingController();
  final TextEditingController _signCtrl = new TextEditingController();

  final String _signHint = '''
{
  "address": "0x ...",
  "msg": "Pay DOTs to the Polkadot account: ...",
  "sig": "0x ...",
  "version": "2"
}
  ''';

  String _statementKind;
  String _amount;
  String _ethSignature;
  String _signError;
  String _claimPrefix;

  Future<void> _onCheckEthAddress(String v) async {
    String ethAddress = v.trim();
    var statement = await ClaimUtil.fetchStatementKind(webApi, ethAddress);
    setState(() {
      _statementKind = statement ?? '';
    });
    if (statement != null) {
      _getClaimPrefix();
    }
    return statement;
  }

  Future<void> _onCheckSignature(String v) async {
    try {
      String value = v.trim();
      Map res = jsonDecode(value);
      print(res);
      String signAddress = res['address'];
      if (signAddress != null) {
        if (signAddress.toLowerCase() !=
            _addressCtrl.text.trim().toLowerCase()) {
          setState(() {
            _signError = 'Signature ETH address mismatch';
          });
          return;
        }
        String amount = await ClaimUtil.fetchClaimAmount(webApi, signAddress);
        setState(() {
          _amount = amount ?? '';
          _signError = null;
        });
        _fetchEthSignature(value);
      } else {
        setState(() {
          _amount = null;
          _signError = 'Invalid Signature';
        });
      }
    } catch (err) {
      setState(() {
        _amount = null;
        _signError = 'Invalid Signature';
      });
    }
  }

  Future<void> _fetchEthSignature(String value) async {
    Map res = await webApi.evalJavascript('claim.recoverFromJSON(`$value`)');
    print(res);
    if (res['error'] != null) {
      setState(() {
        _amount = null;
        _signError = res['error'];
      });
    } else {
      setState(() {
        _ethSignature = res['signature'];
      });
    }
  }

  Future<void> _getClaimPrefix() async {
    String prefix = await webApi.evalJavascript(
        'claim.getClaimPrefix("${widget.store.account.currentAddress}")');
    setState(() {
      _claimPrefix = prefix;
    });
  }

  Future<void> _onSubmit() async {
    final Map dic = I18n.of(context).assets;
    final String statement = ClaimUtil.getStatementSentence(_statementKind);
    final String pubKey = widget.store.account.currentAccount.pubKey;
    final String accountId = widget.store.account.pubKeyAddressMap[0][pubKey];
    var args = {
      "title": dic['claim'],
      "txInfo": {
        "module": 'claims',
        "call": 'claimAttest',
        "isUnsigned": true,
      },
      "detail": jsonEncode({
        "accountId": accountId,
        "ethereumSignature": _ethSignature,
        "statement": statement,
      }),
      "params": [
        accountId,
        _ethSignature,
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
  void dispose() {
    _addressCtrl.dispose();
    _signCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).assets;

    bool isRegular = _statementKind == 'Regular';
    String statementSentence = ClaimUtil.getStatementSentence(_statementKind);
    final String payload = '$_claimPrefix$statementSentence';
    return Scaffold(
      appBar: AppBar(
        title: Text(dic['claim']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text(
              dic['claim.eth.title'],
              style: Theme.of(context).textTheme.headline4,
            ),
            TextFormField(
              decoration: InputDecoration(
                hintText: dic['claim.eth'],
                labelText: dic['claim.eth'],
                suffix: GestureDetector(
                  child: Icon(
                    CupertinoIcons.clear_thick_circled,
                    color: Theme.of(context).disabledColor,
                    size: 18,
                  ),
                  onTap: () {
                    WidgetsBinding.instance
                        .addPostFrameCallback((_) => _addressCtrl.clear());
                  },
                ),
              ),
              controller: _addressCtrl,
              onChanged: (v) => _onCheckEthAddress(v),
            ),
            _statementKind == null
                ? Container()
                : _statementKind.isEmpty
                    ? Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: _NoClaimDisplay(_addressCtrl.text.trim()),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 16, bottom: 12),
                            child: Text(
                              dic['claim.terms'],
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ),
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
                          Container(
                            height: 160,
                            margin: EdgeInsets.only(top: 8, bottom: 8),
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
//                                  color: Theme.of(context).dividerColor,
                              border: Border.all(
                                  color: Theme.of(context).disabledColor),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                            ),
                            child: ListView(
                              children: [
                                Text(isRegular
                                    ? dot_claim_terms_regular
                                    : dot_claim_terms_saft)
                              ],
                            ),
                          ),
                          Text(
                            dic['claim.eth.copy'],
                            style: TextStyle(fontSize: 16),
                          ),
                          GestureDetector(
                            child: Container(
                              margin: EdgeInsets.only(top: 8),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).dividerColor,
                                border: Border.all(
                                    color: Theme.of(context).disabledColor),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                              ),
                              child: Text(payload),
                            ),
                            onTap: () => UI.copyAndNotify(context, payload),
                          ),
                          TextFormField(
                            maxLines: 6,
                            decoration: InputDecoration(
                              helperMaxLines: 6,
                              hintText: _signHint,
                              labelText: dic['claim.eth.sign'],
                              suffix: GestureDetector(
                                child: Icon(
                                  CupertinoIcons.clear_thick_circled,
                                  color: Theme.of(context).disabledColor,
                                  size: 18,
                                ),
                                onTap: () {
                                  WidgetsBinding.instance.addPostFrameCallback(
                                      (_) => _signCtrl.clear());
                                },
                              ),
                            ),
                            controller: _signCtrl,
                            onChanged: (v) => _onCheckSignature(v),
                          ),
                          _signError != null
                              ? Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    _signError,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                )
                              : Container(),
                          Container(height: 16),
                          _amount != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dic['claim.eth'],
                                      style: TextStyle(
                                          color: _amount.isEmpty
                                              ? Colors.red
                                              : null),
                                    ),
                                    Text(
                                      Fmt.address(_addressCtrl.text.trim()),
                                      style: TextStyle(
                                          color: _amount.isEmpty
                                              ? Colors.red
                                              : null),
                                    ),
                                    _amount.isEmpty
                                        ? _NoClaimDisplay(
                                            _addressCtrl.text.trim(),
                                            afterSign: true,
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${dic['claim.amount']} $_amount',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline4,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: 16, bottom: 8),
                                                child: RoundedButton(
                                                  text: dic['claim'],
                                                  onPressed:
                                                      _ethSignature != null
                                                          ? () => _onSubmit()
                                                          : null,
                                                ),
                                              )
                                            ],
                                          ),
                                  ],
                                )
                              : Container(),
                        ],
                      ),
          ],
        ),
      ),
    );
  }
}

class _NoClaimDisplay extends StatelessWidget {
  _NoClaimDisplay(this.ethAddress, {this.afterSign});

  final String ethAddress;
  final bool afterSign;

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).assets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dic['claim.eth'],
          style: TextStyle(color: Colors.red),
        ),
        Text(
          Fmt.address(ethAddress),
          style: TextStyle(color: Colors.red),
        ),
        Text(
          '${dic['claim.empty']} ${afterSign ?? false ? dic['claim.empty2'] : ''}',
          style: TextStyle(color: Colors.red),
        ),
      ],
    );
  }
}
