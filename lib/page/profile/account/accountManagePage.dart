import 'package:encointer_wallet/common/components/addressIcon.dart';
import 'package:encointer_wallet/common/components/passwordInputDialog.dart';
import 'package:encointer_wallet/common/theme.dart';
import 'package:encointer_wallet/page/profile/account/exportResultPage.dart';
import 'package:encointer_wallet/page/profile/contacts/accountSharePage.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/account/account.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/store/encointer/types/communities.dart';
import 'package:encointer_wallet/utils/format.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:encointer_wallet/utils/translations/translations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';

class AccountManagePage extends StatefulWidget {
  AccountManagePage(this.store);

  static final String route = '/profile/account';
  final AppStore store;

  @override
  _AccountManagePageState createState() => _AccountManagePageState(store);
}

enum options { delete, export }

class _AccountManagePageState extends State<AccountManagePage> {
  _AccountManagePageState(this.store);

  final AppStore store;
  TextEditingController _nameCtrl;
  bool _isEditingText = false;

  @override
  void initState() {
    super.initState();
    if (store.encointer.chosenCid != null) webApi.encointer.getBootstrappers();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _onDeleteAccount(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(I18n.of(context).translationsForLocale().profile.accountDelete),
          actions: <Widget>[
            CupertinoButton(
              child: Text(I18n.of(context).translationsForLocale().home.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoButton(
              child: Text(I18n.of(context).translationsForLocale().home.ok),
              onPressed: () => {
                store.account.removeAccount(store.account.currentAccount).then(
                  (_) async {
                    // refresh balance
                    await store.loadAccountCache();
                    webApi.fetchAccountData();
                    Navigator.of(context).pop();
                  },
                ),
              },
            ),
          ],
        );
      },
    );
  }

  List<Widget> _getBalances() {
    final TextStyle h3 = Theme.of(context).textTheme.headline3;
    final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    CommunityMetadata cm = store.encointer.communityMetadata;
    String name = cm != null ? cm.name : '';
    String symbol = cm != null ? cm.symbol : '';
    final String tokenView = Fmt.tokenView(symbol);
    return store.encointer.balanceEntries.entries.map((i) {
      if (cm != null) {
        return ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
          leading: CommunityIcon(
              store: store, icon: webApi.ipfs.getCommunityIcon(store.encointer.communityIconsCid, devicePixelRatio)),
          title: Text(name, style: h3),
          subtitle: Text(tokenView, style: h3),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${Fmt.doubleFormat(store.encointer.communityBalance)} ⵐ',
                style: h3.copyWith(color: encointerGrey),
              ),
            ],
          ),
        );
      } else
        return Container();
    }).toList();
  }

  void _showPasswordDialog(BuildContext context) {
    final Translations dic = I18n.of(context).translationsForLocale();
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return showPasswordInputDialog(context, store.account.currentAccount, Text(dic.profile.deleteConfirm),
            (password) async {
          print('password is: $password');
          setState(() {
            store.settings.setPin(password);
          });

          bool isMnemonic =
              await store.account.checkSeedExist(AccountStore.seedTypeMnemonic, store.account.currentAccount.pubKey);

          if (isMnemonic) {
            String seed = await store.account
                .decryptSeed(store.account.currentAccount.pubKey, AccountStore.seedTypeMnemonic, password);

            Navigator.of(context).pushNamed(ExportResultPage.route, arguments: {
              'key': seed,
              'type': AccountStore.seedTypeMnemonic,
            });
          } else {
            // Assume that the account was imported via `RawSeed` if mnemonic does not exist.
            showCupertinoDialog(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: Text(dic.profile.noMnemonic),
                  content: Text(dic.profile.noMnemonicTxt),
                  actions: <Widget>[
                    CupertinoButton(
                      child: Text(I18n.of(context).translationsForLocale().home.ok),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                );
              },
            );
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle h3 = Theme.of(context).textTheme.headline3;
    final isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;
    _nameCtrl = TextEditingController(text: store.account.currentAccount.name);
    _nameCtrl.selection = TextSelection.fromPosition(TextPosition(offset: _nameCtrl.text.length));

    final Translations dic = I18n.of(context).translationsForLocale();
    return Observer(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: _isEditingText
              ? TextFormField(
                  controller: _nameCtrl,
                  validator: (v) {
                    String name = v.trim();
                    if (name.length == 0) {
                      return dic.profile.contactNameError;
                    }
                    int exist = store.account.optionalAccounts.indexWhere((i) => i.name == name);
                    if (exist > -1) {
                      return dic.profile.contactNameExist;
                    }
                    return null;
                  },
                )
              : Text(_nameCtrl.text),
          actions: <Widget>[
            !_isEditingText
                ? IconButton(
                    icon: Icon(
                      Iconsax.edit,
                    ),
                    onPressed: () {
                      setState(() {
                        _isEditingText = true;
                      });
                    },
                  )
                : IconButton(
                    icon: Icon(
                      Icons.check,
                    ),
                    onPressed: () {
                      store.account.updateAccountName(_nameCtrl.text.trim());
                      setState(() {
                        _isEditingText = false;
                      });
                    },
                  )
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 20),
                      if (!isKeyboard)
                        AddressIcon(
                          '',
                          size: 130,
                          pubKey: store.account.currentAccount.pubKey,
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(Fmt.address(store.account.currentAddress), style: TextStyle(fontSize: 20)),
                          IconButton(
                            icon: Icon(Iconsax.copy),
                            color: ZurichLion.shade500,
                            onPressed: () {
                              final data = ClipboardData(text: store.account.currentAddress);
                              Clipboard.setData(data);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('✓   ${dic.profile.copiedToClipBoard}')),
                              );
                            },
                          ),
                        ],
                      ),
                      Text(dic.encointer.communities,
                          style: h3.copyWith(color: encointerGrey), textAlign: TextAlign.left),
                    ],
                  ),
                ),
                Expanded(child: ListView(children: _getBalances())),
                Container(
                  // width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(16), // make splash animation as high as the container
                          primary: Colors.transparent,
                          onPrimary: Colors.white,
                          shadowColor: Colors.transparent,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Iconsax.share),
                            SizedBox(width: 12),
                            Text(dic.profile.accountShare, style: h3.copyWith(color: Colors.white)),
                          ],
                        ),
                        onPressed: () => Navigator.pushNamed(context, AccountSharePage.route),
                      ),
                      Spacer(),
                      Container(
                        child: PopupMenuButton<options>(
                          offset: Offset(-10, -150),
                          icon: Icon(Iconsax.more, color: Colors.white),
                          color: ZurichLion.shade50,
                          padding: EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          onSelected: (options result) {
                            switch (result) {
                              case options.delete:
                                _onDeleteAccount(context);
                                break;
                              case options.export:
                                _showPasswordDialog(context);
                                break;
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<options>>[
                            const PopupMenuItem<options>(
                              value: options.delete,
                              child: ListTileTheme(
                                textColor: Color(0xFF3969AC), // ZurichLion.shade500 or 600
                                iconColor: Color(0xFF3969AC), // ZurichLion.shade500 or 600
                                child: ListTile(
                                  minLeadingWidth: 0,
                                  title: Text('Delete'),
                                  leading: Icon(Iconsax.trash),
                                ),
                              ),
                            ),
                            const PopupMenuItem<options>(
                              value: options.export,
                              child: ListTileTheme(
                                textColor: Color(0xFF3969AC), // ZurichLion.shade500 or 600
                                iconColor: Color(0xFF3969AC), // ZurichLion.shade500 or 600
                                child: ListTile(
                                  minLeadingWidth: 0,
                                  title: Text('Export'),
                                  leading:
                                      Icon(Iconsax.export_3, color: Color(0xFF3969AC)), // ZurichLion.shade500 or 600
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CommunityIcon extends StatelessWidget {
  const CommunityIcon({
    Key key,
    @required this.store,
    @required this.icon,
  }) : super(key: key);

  final AppStore store;
  final Image icon;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 50,
          height: 50,
          child: icon,
        ),
        Observer(
          builder: (_) {
            if (store.encointer.bootstrappers != null &&
                store.encointer.bootstrappers.contains(store.account.currentAddress)) {
              return Positioned(
                bottom: 0, right: 0, //give the values according to your requirement
                child: Icon(Iconsax.star, color: Colors.yellow),
              );
            } else
              return Container(width: 0, height: 0);
          },
        ),
      ],
    );
  }
}
