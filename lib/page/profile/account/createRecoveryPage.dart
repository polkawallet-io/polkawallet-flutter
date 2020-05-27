import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/outlinedButtonSmall.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/common/regInputFormatter.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/page/profile/account/friendListPage.dart';
import 'package:polka_wallet/page/profile/account/recoverySettingPage.dart';
import 'package:polka_wallet/store/account/types/accountData.dart';
import 'package:polka_wallet/store/account/types/accountRecoveryInfo.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class CreateRecoveryPage extends StatefulWidget {
  CreateRecoveryPage(this.store);
  static final String route = '/profile/recovery/create';
  final AppStore store;

  @override
  _CreateRecoveryPage createState() => _CreateRecoveryPage();
}

class _CreateRecoveryPage extends State<CreateRecoveryPage> {
  final FocusNode _delayFocusNode = FocusNode();
  final TextEditingController _delayCtrl = new TextEditingController();

  List<AccountData> _friends = [];
  double _threshold = 1;
  double _delay = 3;
  String _delayError;

  Future<void> _handleFriendsSelect() async {
    var res = await Navigator.of(context)
        .pushNamed(FriendListPage.route, arguments: _friends);
    if (res != null) {
      setState(() {
        _friends = List<AccountData>.of(res);
      });
    }
  }

  void _setDelay(String v, {bool custom = false}) {
    if (!custom) {
      _delayFocusNode.unfocus();
      setState(() {
        _delayCtrl.text = '';
      });
    }
    try {
      double value = double.parse(v.trim());
      if (value == 0) {
        setState(() {
          _delayError = 'err';
        });
      } else {
        setState(() {
          _delay = value;
          _delayError = null;
        });
      }
    } catch (err) {
      setState(() {
        _delayError = 'err';
      });
    }
  }

  void _onValidateSubmit(String pageTitle) {
    if (_delay > 7 || _delay < 1) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          final Map dic = I18n.of(context).profile;
          return CupertinoAlertDialog(
            title:
                Text('${dic['recovery.delay']} $_delay ${dic['recovery.day']}'),
            content: Text(dic['recovery.delay.warn']),
            actions: <Widget>[
              CupertinoButton(
                child: Text(
                  I18n.of(context).home['cancel'],
                  style: TextStyle(
                    color: Theme.of(context).unselectedWidgetColor,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoButton(
                child: Text(I18n.of(context).home['ok']),
                onPressed: () {
                  Navigator.of(context).pop();
                  _onSubmit(pageTitle);
                },
              ),
            ],
          );
        },
      );
    } else {
      _onSubmit(pageTitle);
    }
  }

  void _onSubmit(String pageTitle) {
    final Map dic = I18n.of(context).profile;
    List<String> friends = _friends.map((e) => e.address).toList();
    int delayBlocks = _delay * SECONDS_OF_DAY ~/ 6;
    var args = {
      "title": pageTitle,
      "txInfo": {
        "module": 'recovery',
        "call": 'createRecovery',
      },
      "detail": jsonEncode({
        'friends': friends,
        'threshold': _threshold.toInt(),
        'delay': '$_delay ${dic['recovery.day']}',
      }),
      "params": [friends, _threshold.toInt(), delayBlocks],
      'onFinish': (BuildContext txPageContext, Map res) {
        Navigator.popUntil(
            txPageContext, ModalRoute.withName('/profile/recovery'));
        globalRecoverySettingsRefreshKey.currentState.show();
      }
    };
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final AccountRecoveryInfo recoveryInfo =
          widget.store.account.recoveryInfo;
      final List<AccountData> friends =
          ModalRoute.of(context).settings.arguments;
      if (recoveryInfo.friends != null) {
        int delaySeconds = recoveryInfo.delayPeriod *
            widget.store.settings.networkConst['babe']['expectedBlockTime'] ~/
            1000;
        double delayDays = delaySeconds / SECONDS_OF_DAY;
        setState(() {
          _friends = friends;
          _threshold = recoveryInfo.threshold.toDouble();
          _delay = delayDays;
          _delayCtrl.text = delayDays.toString();
        });
        if (delayDays != 1 && delayDays != 3 && delayDays != 7) {
          _delayFocusNode.requestFocus();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).profile;
    final Color primary = Theme.of(context).primaryColor;
    final Color grey = Theme.of(context).disabledColor;
    final List<AccountData> friends = ModalRoute.of(context).settings.arguments;

    final String pageTitle =
        friends.length > 0 ? dic['recovery.modify'] : dic['recovery.create'];
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          color: Theme.of(context).cardColor,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      title: Text(dic['recovery.friends']),
                      trailing: Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () => _handleFriendsSelect(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: RecoveryFriendList(friends: _friends),
                    ),
                    _friends.length > 1
                        ? Padding(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  dic['recovery.threshold'],
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  '${_threshold.toInt()} / ${_friends.length}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                )
                              ],
                            ),
                          )
                        : Container(),
                    _friends.length > 1
                        ? ThresholdSlider(
                            value: _threshold,
                            friends: _friends,
                            onChanged: (v) {
                              setState(() {
                                _threshold = v;
                              });
                            },
                          )
                        : Container(),
                    Padding(
                      padding: EdgeInsets.only(left: 16, top: 16),
                      child: Text(
                        dic['recovery.delay'],
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          OutlinedButtonSmall(
                            content: '1 ${dic['recovery.day']}',
                            active: _delay == 1,
                            onPressed: () => _setDelay('1'),
                          ),
                          OutlinedButtonSmall(
                            content: '3 ${dic['recovery.day']}',
                            active: _delay == 3,
                            onPressed: () => _setDelay('3'),
                          ),
                          OutlinedButtonSmall(
                            content: '7 ${dic['recovery.day']}',
                            active: _delay == 7,
                            onPressed: () => _setDelay('7'),
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                CupertinoTextField(
                                  padding: EdgeInsets.fromLTRB(12, 3, 12, 3),
                                  placeholder: dic['recovery.custom'],
                                  inputFormatters: [
                                    RegExInputFormatter.withRegex(
                                        '^[0-9]{0,6}(\\.[0-9]{0,2})?\$')
                                  ],
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(24)),
                                    border: Border.all(
                                        width: 0.5,
                                        color: _delayFocusNode.hasFocus
                                            ? primary
                                            : grey),
                                  ),
                                  controller: _delayCtrl,
                                  focusNode: _delayFocusNode,
                                  onChanged: (v) => _setDelay(v, custom: true),
                                  suffix: Container(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Text(
                                      dic['recovery.day'],
                                      style: TextStyle(
                                          color: _delayFocusNode.hasFocus
                                              ? primary
                                              : grey),
                                    ),
                                  ),
                                ),
                                _delayError != null
                                    ? Text(
                                        _delayError,
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 12),
                                      )
                                    : Container()
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: RoundedButton(
                  text: I18n.of(context).home['next'],
                  onPressed: _friends.length > 0 && _delayError == null
                      ? () {
                          _onValidateSubmit(pageTitle);
                        }
                      : null,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ThresholdSlider extends StatelessWidget {
  ThresholdSlider({this.value, this.friends, this.onChanged});

  final List<AccountData> friends;
  final double value;
  final Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    TextStyle h4 = Theme.of(context).textTheme.headline4;
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Row(
        children: [
          Text('1', style: h4),
          Expanded(
            child: CupertinoSlider(
              min: 1,
              max: friends.length.toDouble(),
              divisions: friends.length - 1,
              value: value,
              onChanged: onChanged,
            ),
          ),
          Text(friends.length.toString(), style: h4),
        ],
      ),
    );
  }
}
