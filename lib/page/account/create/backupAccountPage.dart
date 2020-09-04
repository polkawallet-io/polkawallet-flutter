import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/accountAdvanceOption.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class BackupAccountPage extends StatefulWidget {
  const BackupAccountPage(this.store);

  static final String route = '/account/backup';
  final AppStore store;

  @override
  _BackupAccountPageState createState() => _BackupAccountPageState(store);
}

class _BackupAccountPageState extends State<BackupAccountPage> {
  _BackupAccountPageState(this.store);

  final AppStore store;

  AccountAdvanceOptionParams _advanceOptions = AccountAdvanceOptionParams();
  int _step = 0;

  List<String> _wordsSelected;
  List<String> _wordsLeft;

  bool _submitting = false;

  Future<void> _importAccount() async {
    setState(() {
      _submitting = true;
    });
    var acc = await webApi.account.importAccount(
      cryptoType:
          _advanceOptions.type ?? AccountAdvanceOptionParams.encryptTypeSR,
      derivePath: _advanceOptions.path ?? '',
    );

    if (acc['error'] != null) {
      UI.alertWASM(context, () {
        setState(() {
          _submitting = false;
          _step = 0;
        });
      });
      return;
    }

    await store.account.addAccount(acc, store.account.newAccount.password);
    webApi.account.encodeAddress([acc['pubKey']]);

    store.assets.loadAccountCache();
    store.staking.loadAccountCache();

    // fetch info for the imported account
    String pubKey = acc['pubKey'];
    webApi.assets.fetchBalance();
    webApi.staking.fetchAccountStaking();
    webApi.account.fetchAccountsBonded([pubKey]);
    webApi.account.getPubKeyIcons([pubKey]);

    setState(() {
      _submitting = false;
    });
    // go to home page
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  @override
  void initState() {
    webApi.account.generateAccount();
    super.initState();
  }

  Widget _buildStep0(BuildContext context) {
    final Map<String, String> i18n = I18n.of(context).account;

    return Observer(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text(I18n.of(context).home['create']),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(top: 16),
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: Text(
                        i18n['create.warn3'],
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        i18n['create.warn4'],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.black12,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(4))),
                      child: Text(
                        store.account.newAccount.key ?? '',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                    AccountAdvanceOption(
                      seed: store.account.newAccount.key ?? '',
                      onChange: (data) {
                        setState(() {
                          _advanceOptions = data;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: RoundedButton(
                  text: I18n.of(context).home['next'],
                  onPressed: () {
                    if (_advanceOptions.error ?? false) return;
                    setState(() {
                      _step = 1;
                      _wordsSelected = <String>[];
                      _wordsLeft = store.account.newAccount.key.split(' ');
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1(BuildContext context) {
    final Map<String, String> i18n = I18n.of(context).account;

    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).home['create']),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            setState(() {
              _step = 0;
            });
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16),
                children: <Widget>[
                  Text(
                    i18n['backup'],
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      i18n['backup.confirm'],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      GestureDetector(
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            i18n['backup.reset'],
                            style: TextStyle(fontSize: 14, color: Colors.pink),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _wordsLeft =
                                store.account.newAccount.key.split(' ');
                            _wordsSelected = [];
                          });
                        },
                      )
                    ],
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
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                  _buildWordsButtons(),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: RoundedButton(
                submitting: _submitting,
                text: I18n.of(context).home['next'],
                onPressed:
                    _wordsSelected.join(' ') == store.account.newAccount.key
                        ? () => _importAccount()
                        : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordsButtons() {
    if (_wordsLeft.length > 0) {
      _wordsLeft.sort();
    }

    List<Widget> rows = <Widget>[];
    for (var r = 0; r * 3 < _wordsLeft.length; r++) {
      if (_wordsLeft.length > r * 3) {
        rows.add(Row(
          children: _wordsLeft
              .getRange(
                  r * 3,
                  _wordsLeft.length > (r + 1) * 3
                      ? (r + 1) * 3
                      : _wordsLeft.length)
              .map(
                (i) => Container(
                  padding: EdgeInsets.only(left: 4, right: 4),
                  child: RaisedButton(
                    child: Text(
                      i,
                    ),
                    onPressed: () {
                      setState(() {
                        _wordsLeft.remove(i);
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
