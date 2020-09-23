import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

enum ValidatorSortOptions { staked, points, commission, judgements }

class ValidatorListFilter extends StatefulWidget {
  ValidatorListFilter(
      {this.onFilterChange, this.onSortChange, this.needSort = true});
  final Function(String) onFilterChange;
  final Function(int) onSortChange;
  final bool needSort;
  @override
  _ValidatorListFilterState createState() => _ValidatorListFilterState();
}

class _ValidatorListFilterState extends State<ValidatorListFilter> {
  int _sort = 0;

  void _showActions() {
    var dic = I18n.of(context).staking;
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: ValidatorSortOptions.values
            .map((i) => CupertinoActionSheetAction(
                  child: Text(dic[i.toString().split('.')[1]]),
                  onPressed: () {
                    setState(() {
                      _sort = i.index;
                    });
                    Navigator.of(context).pop();
                    widget.onSortChange(i.index);
                  },
                ))
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          child: Text(I18n.of(context).home['cancel']),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).staking;
    var theme = Theme.of(context);
    return Container(
      color: theme.cardColor,
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 16),
              child: CupertinoTextField(
                clearButtonMode: OverlayVisibilityMode.editing,
                padding: EdgeInsets.fromLTRB(16, 6, 16, 6),
                placeholder: dic['filter'],
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                  border: Border.all(width: 0.5, color: theme.dividerColor),
                ),
                onChanged: (value) => widget.onFilterChange(value.trim()),
              ),
            ),
          ),
          widget.needSort
              ? Row(
                  children: <Widget>[
                    Text(dic['sort']),
                    GestureDetector(
                      child: Container(
                        margin: EdgeInsets.only(left: 8),
                        padding: EdgeInsets.fromLTRB(16, 6, 16, 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                          border:
                              Border.all(width: 0.5, color: theme.dividerColor),
                        ),
                        child: Text(dic[ValidatorSortOptions.values[_sort]
                            .toString()
                            .split('.')[1]]),
                      ),
                      onTap: _showActions,
                    )
                  ],
                )
              : Container(height: 8)
        ],
      ),
    );
  }
}
