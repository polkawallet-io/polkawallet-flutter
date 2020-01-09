import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/utils/i18n.dart';

import 'package:polka_wallet/utils/localStorage.dart';

class BackupAccount extends StatefulWidget {
  const BackupAccount(this.emitMsg, this.accountCreate);

  final Function emitMsg;
  final Map<String, dynamic> accountCreate;

  @override
  _BackupAccountState createState() =>
      _BackupAccountState(emitMsg, accountCreate);
}

class _BackupAccountState extends State<BackupAccount> {
  _BackupAccountState(this.emitMsg, this.accountCreate);

  final Function emitMsg;
  final Map<String, dynamic> accountCreate;

  int _step = 0;

  List<String> _wordsSelected;

  @override
  void initState() {
    emitMsg('get', {'path': '/account/gen'});
    super.initState();
  }

  Widget _buildStep0(BuildContext context) {
    final Map<String, String> i18n = I18n.of(context).account;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: <Widget>[
                Text(
                  i18n['create.warn3'],
                  style: Theme.of(context).textTheme.display4,
                ),
                Container(
                  padding: EdgeInsets.only(top: 16, bottom: 32),
                  child: Text(
                    i18n['create.warn4'],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black12,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(4))),
                  padding: EdgeInsets.all(16),
                  child: Text(
                    accountCreate['mnemonic'] ?? '',
                    style: Theme.of(context).textTheme.display3,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: RaisedButton(
                    padding: EdgeInsets.all(16),
                    color: Colors.pink,
                    child: Text(I18n.of(context).home['next'],
                        style: Theme.of(context).textTheme.button),
                    onPressed: () {
                      setState(() {
                        _step = 1;
                        _wordsSelected = <String>[];
                      });
                    },
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStep1(BuildContext context) {
    final Map<String, String> i18n = I18n.of(context).account;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _step = 0;
            });
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: <Widget>[
                Text(
                  i18n['backup'],
                  style: Theme.of(context).textTheme.display4,
                ),
                Container(
                  padding: EdgeInsets.only(top: 16, bottom: 32),
                  child: Text(
                    i18n['backup.confirm'],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black12,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(4))),
                  padding: EdgeInsets.all(16),
                  child: Text(
                    _wordsSelected.join(' ') ?? '',
                    style: Theme.of(context).textTheme.display3,
                  ),
                ),
                _buildWordsButtons(),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: RaisedButton(
                    padding: EdgeInsets.all(16),
                    color: Colors.pink,
                    child: Text(I18n.of(context).home['next'],
                        style: Theme.of(context).textTheme.button),
                    onPressed: _wordsSelected.length == 12
                        ? () async {
                            String acc = await LocalStorage.getItem('acc');
                            print('get from local storage: $acc');
                            print('set to storage');
                            print(accountCreate);
                            LocalStorage.setItem(
                                'acc', accountCreate.toString());
                            Navigator.pushNamed(context, '/');
                          }
                        : null,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildWordsButtons() {
    List<String> wordsAll = accountCreate['mnemonic'].toString().split(' ');
    List<String> wordsLeft = List<String>.of(wordsAll);
    for (var i in wordsAll) {
      if (_wordsSelected.indexOf(i) > -1) {
        wordsLeft.remove(i);
      }
    }
    if (wordsLeft.length > 0) {
      wordsLeft.sort();
    }

    List<Widget> rows = <Widget>[];
    for (var r = 0; r * 3 < wordsLeft.length; r++) {
      if (wordsLeft.length > r * 3) {
        rows.add(Row(
          children: wordsLeft
              .getRange(
                  r * 3,
                  wordsLeft.length > (r + 1) * 3
                      ? (r + 1) * 3
                      : wordsLeft.length)
              .map(
                (i) => Container(
                  padding: EdgeInsets.only(left: 4, right: 4),
                  child: RaisedButton(
                    child: Text(
                      i,
                    ),
                    onPressed: () {
                      setState(() {
                        _wordsSelected.add(i);
                      });
                    },
                  ),
                ),
              )
              .toList(),
        ));
      }
    }
    return Container(
      padding: EdgeInsets.only(top: 16),
      child: Column(
        children: rows,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case 0:
        return _buildStep0(context);
      case 1:
        return _buildStep1(context);
      default:
        return Container();
    }
  }
}
