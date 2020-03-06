import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class AccountAdvanced extends StatefulWidget {
  AccountAdvanced({this.onCryptoTypeChange, this.onDerivePathChange});
  final void Function(int) onCryptoTypeChange;
  final void Function(String) onDerivePathChange;

  @override
  _AccountAdvancedState createState() => _AccountAdvancedState(
      onCryptoTypeChange: onCryptoTypeChange,
      onDerivePathChange: onDerivePathChange);
}

class _AccountAdvancedState extends State<AccountAdvanced> {
  _AccountAdvancedState({this.onCryptoTypeChange, this.onDerivePathChange});
  final void Function(int) onCryptoTypeChange;
  final void Function(String) onDerivePathChange;

  final List<String> _typeOptions = ['sr25519', 'ed25519'];

  int _typeSelection = 0;
  String _path = '';

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).account;
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 8),
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  _expanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  size: 30,
                  color: Theme.of(context).unselectedWidgetColor,
                ),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
              Text(dic['advanced'])
            ],
          ),
        ),
        _expanded
            ? ListTile(
                title: Text(I18n.of(context).account['import.encrypt']),
                subtitle: Text(_typeOptions[_typeSelection]),
                trailing: Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (_) => Container(
                      height: MediaQuery.of(context).copyWith().size.height / 3,
                      child: CupertinoPicker(
                        backgroundColor: Colors.white,
                        itemExtent: 56,
                        scrollController: FixedExtentScrollController(
                            initialItem: _typeSelection),
                        children: _typeOptions
                            .map((i) => Padding(
                                padding: EdgeInsets.all(16), child: Text(i)))
                            .toList(),
                        onSelectedItemChanged: (v) {
                          setState(() {
                            _typeSelection = v;
                          });
                          onCryptoTypeChange(v);
                        },
                      ),
                    ),
                  );
                },
              )
            : Container(),
//        _expanded
//            ? Padding(
//                padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
//                child: TextFormField(
//                  decoration: InputDecoration(
//                    hintText: '//hard/soft///password',
//                    labelText: dic['path'],
//                  ),
//                  initialValue: _path,
//                  onChanged: (v) {
//                    setState(() {
//                      _path = v;
//                    });
//                    onDerivePathChange(v);
//                  },
//                ),
//              )
//            : Container(),
      ],
    );
  }
}
