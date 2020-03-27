import 'package:flutter/material.dart';
import 'package:polka_wallet/store/app.dart';

class Loan extends StatefulWidget {
  Loan(this.store);

  final AppStore store;

  @override
  _LoanState createState() => _LoanState(store);
}

class _LoanState extends State<Loan> {
  _LoanState(this.store);

  final AppStore store;

  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.only(top: 20),
          color: Colors.transparent,
          child: Column(
            children: <Widget>[Text('Loan')],
          ),
        ),
      ),
    );
  }
}
