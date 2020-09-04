import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/account/types/accountData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/format.dart';

class AddressInputField extends StatefulWidget {
  AddressInputField(this.store,
      {this.label, this.initialValue, this.onChanged});
  final AppStore store;
  final String label;
  final AccountData initialValue;
  final Function(AccountData) onChanged;
  @override
  _AddressInputFieldState createState() => _AddressInputFieldState();
}

class _AddressInputFieldState extends State<AddressInputField> {
  Future<List<AccountData>> _getAccountsFromInput(String input) async {
    final listLocal = widget.store.account.accountList.toList();
    listLocal.addAll(widget.store.settings.contactList);
    // return local account list if input empty
    if (input.isEmpty || input.trim().length < 3) {
      return listLocal;
    }

    // check if user input is valid address or indices
    final checkAddress = await webApi.account.decodeAddress([input]);
    if (checkAddress == null) {
      return listLocal;
    }

    final acc = AccountData();
    acc.address = input;
    if (input.length < 47) {
      // check if input indices in local account list
      final int indicesIndex = listLocal.indexWhere((e) {
        final Map accInfo = widget.store.account.addressIndexMap[e.address];
        return accInfo != null && accInfo['accountIndex'] == input;
      });
      if (indicesIndex >= 0) {
        return [listLocal[indicesIndex]];
      }
      // query account address with account indices
      final queryRes = await webApi.account.queryAddressWithAccountIndex(input);
      if (queryRes != null) {
        acc.address = queryRes[0];
        acc.name = input;
      }
    } else {
      // check if input address in local account list
      final int addressIndex =
          listLocal.indexWhere((e) => _itemAsString(e).contains(input));
      if (addressIndex >= 0) {
        return [listLocal[addressIndex]];
      }
    }

    // fetch address info if it's a new address
    final res = await webApi.account.getAddressIcons([acc.address]);
    if (res != null) {
      await webApi.account.fetchAddressIndex([acc.address]);
    }
    return [acc];
  }

  String _itemAsString(AccountData item) {
    final String address = Fmt.addressOfAccount(item, widget.store);
    final Map accInfo = widget.store.account.addressIndexMap[item.address];
    String idx = '';
    if (accInfo != null && accInfo['accountIndex'] != null) {
      idx = accInfo['accountIndex'];
    }
    if (item.name != null) {
      return '${item.name} $idx $address ${item.address}';
    }
    return '${Fmt.accountDisplayNameString(address, accInfo)} $idx $address ${item.address}';
  }

  Widget _selectedItemBuilder(
      BuildContext context, AccountData item, String itemDesignation) {
    if (item == null) {
      return Container();
    }
    return Observer(
      builder: (_) {
        final Map accInfo = widget.store.account.addressIndexMap[item.pubKey];
        final String address = Fmt.addressOfAccount(item, widget.store);
        return Container(
          padding: EdgeInsets.only(top: 8),
          child: Row(
            children: [
              AddressIcon(item.address, pubKey: item.pubKey, tapToCopy: false),
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Fmt.address(address)),
                    Text(
                      item.name.isNotEmpty
                          ? item.name
                          : Fmt.accountDisplayNameString(item.address, accInfo),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).unselectedWidgetColor,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _listItemBuilder(
      BuildContext context, AccountData item, bool isSelected) {
    return Observer(
      builder: (_) {
        final Map accInfo = widget.store.account.addressIndexMap[item.pubKey];
        final String address = Fmt.addressOfAccount(item, widget.store);
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          decoration: !isSelected
              ? null
              : BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                ),
          child: ListTile(
            selected: isSelected,
            dense: true,
            title: Text(Fmt.address(address)),
            subtitle: Text(
              item.name.isNotEmpty
                  ? item.name
                  : Fmt.accountDisplayNameString(item.address, accInfo),
            ),
            leading: CircleAvatar(
              child: AddressIcon(item.address, pubKey: item.pubKey),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<AccountData>(
      mode: Mode.BOTTOM_SHEET,
      isFilteredOnline: true,
      showSearchBox: true,
      showSelectedItem: true,
      autoFocusSearchBox: true,
      searchBoxDecoration: InputDecoration(hintText: widget.label),
      label: widget.label,
      selectedItem: widget.initialValue,
      compareFn: (AccountData i, s) => i.pubKey == s?.pubKey,
      validator: (AccountData u) =>
          u == null ? "user field is required " : null,
      onFind: (String filter) => _getAccountsFromInput(filter),
      itemAsString: _itemAsString,
      onChanged: (AccountData data) {
        if (widget.onChanged != null) {
          widget.onChanged(data);
        }
      },
      dropdownBuilder: _selectedItemBuilder,
      popupItemBuilder: _listItemBuilder,
    );
  }
}
