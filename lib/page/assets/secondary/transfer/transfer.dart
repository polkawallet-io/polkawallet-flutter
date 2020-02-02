import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/service/api.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/store/settings.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class Transfer extends StatefulWidget {
  const Transfer(this.api, this.accountStore, this.settingsStore);

  final Api api;
  final AccountStore accountStore;
  final SettingsStore settingsStore;

  @override
  _TransferState createState() =>
      _TransferState(api, accountStore, settingsStore);
}

class _TransferState extends State<Transfer> {
  _TransferState(this.api, this.accountStore, this.settingsStore);

  final Api api;
  final AccountStore accountStore;
  final SettingsStore settingsStore;

  int _step = 0;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _addressCtrl = new TextEditingController();
  final TextEditingController _amountCtrl = new TextEditingController();
  final TextEditingController _passCtrl = new TextEditingController();

  Widget _buildStep0(BuildContext context) {
    Map<String, String> dic = I18n.of(context).assets;
    String symbol = settingsStore.networkState.tokenSymbol;
    return ListView(
      children: <Widget>[
        Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(16),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: dic['address'],
                    labelText: dic['address'],
                  ),
                  controller: _addressCtrl,
                  validator: (v) {
                    return v.trim().length == 47 ? null : dic['address.error'];
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: dic['amount'],
                    labelText: dic['amount'],
                  ),
                  controller: _amountCtrl,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: Text('TransferFee: ${settingsStore.transferFeeView} $symbol',
              style: TextStyle(fontSize: 16, color: Colors.black54)),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: Text('CreationFee: ${settingsStore.creationFeeView} $symbol',
              style: TextStyle(fontSize: 16, color: Colors.black54)),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: RaisedButton(
                  color: Colors.pink,
                  padding: EdgeInsets.all(16),
                  child: Text(
                    I18n.of(context).assets['make'],
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      setState(() {
                        _step = 1;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildStep1(BuildContext context) {
    Map<String, String> dic = I18n.of(context).home;
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  dic['submit.tx'],
                  style: Theme.of(context).textTheme.display4,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '${dic["submit.from"]}${accountStore.currentAccount.address}',
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '${dic["submit.call"]}blances.transfer',
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: TextFormField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.lock),
                    hintText: dic['unlock'],
                    labelText: dic['unlock'],
                  ),
                  obscureText: true,
                  controller: _passCtrl,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                color: Colors.orange,
                child: FlatButton(
                  padding: EdgeInsets.all(16),
                  child: Text(dic['cancel'],
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    _passCtrl.value = TextEditingValue(text: '');
                    setState(() {
                      _step = 0;
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.pink,
                child: FlatButton(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    dic['submit'],
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    api.transfer(_addressCtrl.text,
                        double.parse(_amountCtrl.text), _passCtrl.text);
                  },
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> dic = I18n.of(context).assets;
    String symbol = settingsStore.networkState.tokenSymbol;
    return Scaffold(
      appBar: AppBar(
        title: Text('${dic['transfer']} $symbol'),
        centerTitle: true,
      ),
      body: _step == 0 ? _buildStep0(context) : _buildStep1(context),
    );
  }
}
