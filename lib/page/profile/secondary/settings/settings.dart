import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/store/settings.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class Settings extends StatefulWidget {
  Settings(this.store, this.changeLang);
  final SettingsStore store;
  final Function changeLang;
  @override
  _Settings createState() => _Settings(store, changeLang);
}

class _Settings extends State<Settings> {
  _Settings(this.store, this.changeLang);

  final SettingsStore store;
  final Function changeLang;

  final _langOptions = [null, 'en', 'zh'];

  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).profile;

    String getLang(String code) {
      switch (code) {
        case 'zh':
          return '简体中文';
        case 'en':
          return 'English';
        default:
          return dic['setting.lang.auto'];
      }
    }

    void _onLanguageTap() {
      print('tt');
      showCupertinoModalPopup(
        context: context,
        builder: (_) => Container(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          child: WillPopScope(
            child: CupertinoPicker(
              backgroundColor: Colors.white,
              itemExtent: 58,
              scrollController: FixedExtentScrollController(
                  initialItem: _langOptions.indexOf(store.localeCode)),
              children: _langOptions.map((i) {
                return Padding(
                    padding: EdgeInsets.all(16), child: Text(getLang(i)));
              }).toList(),
              onSelectedItemChanged: (v) {
                setState(() {
                  _selected = v;
                });
              },
            ),
            onWillPop: () async {
              changeLang(_langOptions[_selected]);
              return true;
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).profile['setting']),
        centerTitle: true,
      ),
      body: Observer(
        builder: (_) => Padding(
          padding: EdgeInsets.all(8),
          child: ListView(
            children: <Widget>[
              ListTile(
                title: Text(dic['setting.node']),
                subtitle: Text(store.endpoint.text ?? ''),
                trailing: Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () =>
                    Navigator.of(context).pushNamed('/profile/endpoint'),
              ),
              ListTile(
                title: Text(dic['setting.lang']),
                subtitle: Text(getLang(store.localeCode)),
                trailing: Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () => _onLanguageTap(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
