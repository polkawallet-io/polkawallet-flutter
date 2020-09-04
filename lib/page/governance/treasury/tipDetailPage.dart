import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/BorderedTitle.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/page/governance/council/candidateDetailPage.dart';
import 'package:polka_wallet/page/governance/treasury/treasuryPage.dart';
import 'package:polka_wallet/store/account/types/accountData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/gov/types/treasuryTipData.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class TipDetailPage extends StatefulWidget {
  TipDetailPage(this.store);

  static const String route = '/gov/treasury/tip';

  final AppStore store;

  @override
  _TipDetailPageState createState() => _TipDetailPageState();
}

class _TipDetailPageState extends State<TipDetailPage> {
  final TextEditingController _tipInputCtrl = TextEditingController();

  Future<void> _onEndorse() async {
    final String symbol = widget.store.settings.networkState.tokenSymbol;
    final int decimals = widget.store.settings.networkState.tokenDecimals;
    final String tokenView = Fmt.tokenView(symbol);
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        final Map<String, String> dic = I18n.of(context).home;
        final Map<String, String> dicGov = I18n.of(context).gov;
        return CupertinoAlertDialog(
          title: Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
                '${dicGov['treasury.tip']} - ${dicGov['treasury.endorse']}'),
          ),
          content: CupertinoTextField(
            controller: _tipInputCtrl,
            suffix: Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text(tokenView),
            ),
            inputFormatters: [UI.decimalInputFormatter(decimals)],
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          actions: <Widget>[
            CupertinoButton(
              child: Text(dic['cancel']),
              onPressed: () {
                setState(() {
                  _tipInputCtrl.text = '';
                });
                Navigator.of(context).pop();
              },
            ),
            CupertinoButton(
              child: Text(dic['ok']),
              onPressed: () {
                try {
                  final value = double.parse(_tipInputCtrl.text);
                  if (value >= 0) {
                    Navigator.of(context).pop();
                    _onEndorseSubmit();
                  } else {
                    _showTipInvalid();
                  }
                } catch (err) {
                  _showTipInvalid();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showTipInvalid() async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        final Map<String, String> dic = I18n.of(context).home;
        return CupertinoAlertDialog(
          title: Container(),
          content: Text(dic['input.invalid']),
          actions: <Widget>[
            CupertinoButton(
              child: Text(dic['cancel']),
              onPressed: () {
                setState(() {
                  _tipInputCtrl.text = '';
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _onEndorseSubmit() async {
    var dic = I18n.of(context).gov;
    int decimals = widget.store.settings.networkState.tokenDecimals;
    final TreasuryTipData tipData = ModalRoute.of(context).settings.arguments;
    String amt = _tipInputCtrl.text.trim();
    var args = {
      "title": '${dic['treasury.tip']} - ${dic['treasury.endorse']}',
      "txInfo": {
        "module": 'treasury',
        "call": 'tip',
      },
      "detail": jsonEncode({
        "hash": Fmt.address(tipData.hash, pad: 16),
        "tipValue": amt,
      }),
      "params": [
        // "hash"
        tipData.hash,
        // "tipValue"
        Fmt.tokenInt(amt, decimals).toString(),
      ],
      'onFinish': (BuildContext txPageContext, Map res) {
        Navigator.popUntil(
            txPageContext, ModalRoute.withName(TreasuryPage.route));

        globalTipsRefreshKey.currentState.show();
      }
    };
    setState(() {
      _tipInputCtrl.text = '';
    });
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  Future<void> _onCancel() async {
    var dic = I18n.of(context).gov;
    final TreasuryTipData tipData = ModalRoute.of(context).settings.arguments;
    var args = {
      "title": '${dic['treasury.tip']} - ${dic['treasury.retract']}',
      "txInfo": {
        "module": 'treasury',
        "call": 'retractTip',
      },
      "detail": jsonEncode({"hash": Fmt.address(tipData.hash, pad: 16)}),
      "params": [tipData.hash],
      'onFinish': (BuildContext txPageContext, Map res) {
        Navigator.popUntil(
            txPageContext, ModalRoute.withName(TreasuryPage.route));

        globalTipsRefreshKey.currentState.show();
      }
    };
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  Future<void> _onCloseTip() async {
    var dic = I18n.of(context).gov;
    final TreasuryTipData tipData = ModalRoute.of(context).settings.arguments;
    var args = {
      "title": '${dic['treasury.tip']} - ${dic['treasury.closeTip']}',
      "txInfo": {
        "module": 'treasury',
        "call": 'closeTip',
      },
      "detail": jsonEncode({"hash": Fmt.address(tipData.hash, pad: 16)}),
      "params": [tipData.hash],
      'onFinish': (BuildContext txPageContext, Map res) {
        Navigator.popUntil(
            txPageContext, ModalRoute.withName(TreasuryPage.route));

        globalTipsRefreshKey.currentState.show();
      }
    };
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  Future<void> _onTip(BigInt median) async {
    var dic = I18n.of(context).gov;
    final int decimals = widget.store.settings.networkState.tokenDecimals;
    final TreasuryTipData tipData = ModalRoute.of(context).settings.arguments;
    var args = {
      "title": '${dic['treasury.tip']} - ${dic['treasury.jet']}',
      "txInfo": {
        "module": 'treasury',
        "call": 'tip',
      },
      "detail": jsonEncode({
        "hash": Fmt.address(tipData.hash, pad: 16),
        "median": Fmt.token(median, decimals),
      }),
      "params": [tipData.hash, median.toString()],
      'onFinish': (BuildContext txPageContext, Map res) {
        Navigator.popUntil(
            txPageContext, ModalRoute.withName(TreasuryPage.route));

        globalTipsRefreshKey.currentState.show();
      }
    };
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).gov;
    final String symbol = widget.store.settings.networkState.tokenSymbol;
    final int decimals = widget.store.settings.networkState.tokenDecimals;
    final TreasuryTipData tipData = ModalRoute.of(context).settings.arguments;
    final AccountData who = AccountData();
    final AccountData finder = AccountData();
    who.address = tipData.who;
    final Map accInfo = widget.store.account.addressIndexMap[who.address];
    Map accInfoFinder;
    if (tipData.finder != null) {
      finder.address = tipData.finder;
      accInfoFinder = widget.store.account.addressIndexMap[finder.address];
    }
    bool isFinder = false;
    if (widget.store.account.currentAddress == finder.address) {
      isFinder = true;
    }
    bool isCouncil = false;
    widget.store.gov.council.members.forEach((e) {
      if (widget.store.account.currentAddress == e[0]) {
        isCouncil = true;
      }
    });
    bool isTipped = tipData.tips.length > 0;
    int blockTime = 6000;
    if (widget.store.settings.networkConst['treasury'] != null) {
      blockTime =
          widget.store.settings.networkConst['babe']['expectedBlockTime'];
    }

    final List<BigInt> values =
        tipData.tips.map((e) => BigInt.parse(e.value.toString())).toList();
    values.sort();
    final int midIndex = (values.length / 2).floor();
    BigInt median = BigInt.zero;
    if (values.length > 0) {
      median = values.length % 2 > 0
          ? values[midIndex]
          : (values[midIndex - 1] + values[midIndex]) ~/ BigInt.two;
    }
    return Scaffold(
      appBar: AppBar(title: Text(dic['treasury.tip']), centerTitle: true),
      body: SafeArea(
        child: Observer(
          builder: (BuildContext context) {
            final bool canClose = tipData.closes != null &&
                tipData.closes <= widget.store.gov.bestNumber;
            return ListView(
              children: <Widget>[
                RoundedCard(
                  margin: EdgeInsets.all(16),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: AddressIcon(who.address),
                        title: Fmt.accountDisplayName(who.address, accInfo),
                        subtitle: Text(dic['treasury.who']),
                      ),
                      tipData.finder != null
                          ? ListTile(
                              leading: AddressIcon(finder.address),
                              title: Fmt.accountDisplayName(
                                finder.address,
                                accInfoFinder,
                              ),
                              subtitle: Text(dic['treasury.finder']),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    '${Fmt.balance(
                                      tipData.deposit.toString(),
                                      decimals,
                                    )} $symbol',
                                    style:
                                        Theme.of(context).textTheme.headline4,
                                  ),
                                  Text(dic['treasury.bond']),
                                ],
                              ),
                            )
                          : Container(),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Row(
                          children: <Widget>[
                            Text(dic['treasury.reason']),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: TextFormField(
                                  decoration: InputDecoration.collapsed(
                                      hintText: '',
                                      focusColor: Theme.of(context).cardColor),
                                  style: TextStyle(fontSize: 14),
                                  initialValue: tipData.reason,
                                  readOnly: true,
                                  maxLines: 6,
                                  minLines: 1,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Row(
                          children: <Widget>[
                            Text('Hash'),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: Text(
                                  Fmt.address(tipData.hash, pad: 10),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      tipData.closes != null &&
                              tipData.closes > widget.store.gov.bestNumber
                          ? Padding(
                              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                              child: Row(
                                children: <Widget>[
                                  Text(dic['treasury.closeTip']),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            Fmt.blockToTime(
                                              tipData.closes -
                                                  widget.store.gov.bestNumber,
                                              blockTime,
                                            ),
                                          ),
                                          Text('#${tipData.closes}')
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: <Widget>[
                            Divider(height: 24),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: RoundedButton(
                                    color: Colors.orange,
                                    text: I18n.of(context).home['cancel'],
                                    onPressed: isFinder ? _onCancel : null,
                                  ),
                                ),
                                Container(width: 8),
                                Expanded(
                                  child: canClose
                                      ? RoundedButton(
                                          text: dic['treasury.closeTip'],
                                          onPressed:
                                              !isCouncil ? _onCloseTip : null,
                                        )
                                      : RoundedButton(
                                          text: dic['treasury.endorse'],
                                          onPressed:
                                              isCouncil ? _onEndorse : null,
                                        ),
                                ),
                                canClose ? Container() : Container(width: 8),
                                canClose
                                    ? Container()
                                    : RoundedButton(
                                        icon: Icon(
                                          Icons.airplanemode_active,
                                          color: Theme.of(context).cardColor,
                                        ),
                                        text: '',
                                        onPressed: isCouncil && isTipped
                                            ? () => _onTip(median)
                                            : null,
                                      )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                tipData.tips.length > 0
                    ? Container(
                        color: Theme.of(context).cardColor,
                        margin: EdgeInsets.only(top: 8),
                        padding: EdgeInsets.only(top: 8, bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                              child: BorderedTitle(
                                  title:
                                      '${tipData.tips.length} ${dic['treasury.tipper']} (${Fmt.token(median, decimals)} $symbol)'),
                            ),
                            Column(
                              children: tipData.tips.map((e) {
                                final Map accInfo = widget
                                    .store.account.addressIndexMap[e.address];
                                return ListTile(
                                  leading: AddressIcon(e.address),
                                  title: Fmt.accountDisplayName(
                                      e.address, accInfo),
                                  trailing: Text(
                                    '${Fmt.balance(
                                      e.value.toString(),
                                      decimals,
                                    )} $symbol',
                                    style:
                                        Theme.of(context).textTheme.headline4,
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                      CandidateDetailPage.route,
                                      arguments: widget
                                          .store.gov.council.members
                                          .firstWhere((i) {
                                        return i[0] == e.address;
                                      }),
                                    );
                                  },
                                );
                              }).toList(),
                            )
                          ],
                        ),
                      )
                    : Container()
              ],
            );
          },
        ),
      ),
    );
  }
}
