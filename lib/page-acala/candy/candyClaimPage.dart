import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/addressFormItem.dart';
import 'package:polka_wallet/common/components/currencyWithIcon.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/service/walletApi.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class CandyClaimPage extends StatefulWidget {
  CandyClaimPage(this.store);

  static const String route = '/acala/candy';
  final AppStore store;

  @override
  _CandyClaimPageState createState() => _CandyClaimPageState();
}

class _CandyClaimPageState extends State<CandyClaimPage> {
  int _amount = 0;
  bool _claimed = false;
  bool _loading = false;
  bool _submitting = false;

  Future<void> _queryAmount() async {
    setState(() {
      _loading = true;
    });
    final res = await WalletApi.queryCandy(widget.store.account.currentAddress);
    if (res != null) {
      print(res);
      setState(() {
        _amount = List.of(res['message']['candy']).length;
        _claimed = res['message']['claimed'];
      });
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _claim() async {
    setState(() {
      _submitting = true;
    });
    final res = await WalletApi.claimCandy(widget.store.account.currentAddress);
    if (res != null) {
      _queryAmount();
    }
    setState(() {
      _submitting = false;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queryAmount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).acala;
    final titleStyle = Theme.of(context).textTheme.headline4;
    final amountStyle = TextStyle(
      fontSize: 72,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).primaryColor,
    );
    final amt = _claimed ? '0.00' : _amount.toDouble().toStringAsFixed(2);
    return Scaffold(
      appBar: AppBar(title: Text(dic['candy.title']), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            RoundedCard(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 8),
              child: Column(
                children: [
                  Text(dic['candy.amount'], style: titleStyle),
                  Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: AddressFormItem(widget.store.account.currentAccount),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Text(amt, style: amountStyle),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            child: TokenIcon('ACA'),
                            width: 32,
                          ),
                          Text('ACA', style: titleStyle)
                        ],
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Text(amt, style: amountStyle),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            child: CircleAvatar(
                              child: Text('KA'),
                            ),
                            width: 32,
                          ),
                          Text('KAR', style: titleStyle)
                        ],
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: _loading
                        ? CupertinoActivityIndicator()
                        : RoundedButton(
                            submitting: _submitting,
                            text: dic['candy.claim'],
                            onPressed: _amount > 0 && !_claimed ? _claim : null,
                          ),
                  )
                ],
              ),
            ),
            _claimed
                ? Text('${dic['candy.claimed']}: $_amount ACA + $_amount KAR')
                : Container()
          ],
        ),
      ),
    );
  }
}
