import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/page/profile/account/friendListPage.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/format.dart';

class CreateRecoveryPage extends StatefulWidget {
  CreateRecoveryPage(this.store);
  static final String route = '/profile/recovery/create';
  final AppStore store;

  @override
  _CreateRecoveryPage createState() => _CreateRecoveryPage();
}

class _CreateRecoveryPage extends State<CreateRecoveryPage> {
  List<AccountData> _friends = [];
  double _threshold = 1;

  Future<void> _handleFriendsSelect() async {
    var res = await Navigator.of(context)
        .pushNamed(FriendListPage.route, arguments: _friends);
    if (res != null) {
      setState(() {
        _friends = List<AccountData>.of(res);
      });
    }
  }

  void _onSubmit(String pageTitle) {
    var args = {
      "title": pageTitle,
      "txInfo": {
        "module": 'honzon',
        "call": 'adjustLoan',
      },
      "detail": '',
      "params": '',
      'onFinish': (BuildContext txPageContext, Map res) {
        Navigator.popUntil(
            txPageContext, ModalRoute.withName('/profile/recovery'));
//        globalLoanRefreshKey.currentState.show();
      }
    };
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('create recover'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: Text('friends'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => _handleFriendsSelect(),
                  ),
                  Column(
                    children: _friends.map((e) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              margin: EdgeInsets.only(left: 16, right: 8),
                              child: AddressIcon(e.address, size: 32),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.name),
                                Text(
                                  Fmt.address(e.address),
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).unselectedWidgetColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  _friends.length > 1
                      ? Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('threshold'),
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
                      : Container()
                ],
              ),
            ),
            RoundedButton(
              text: 'create or edit',
              onPressed: () {
                _onSubmit('title');
              },
            )
          ],
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
