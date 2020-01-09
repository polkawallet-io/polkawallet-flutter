import 'package:mobx/mobx.dart';

part 'assets.g.dart';

class AssetsStore extends _AssetsStore with _$AssetsStore {
  AssetsStore();
}

abstract class _AssetsStore with Store {
  _AssetsStore();

  @observable
  String description = '';

  @observable
  Map<String, dynamic> newAccount = ObservableMap.of(Map<String, dynamic>.from({
    'name': '',
    'password': '',
    'address': '',
    'seed': '',
    'isLocked': false,
    'mnemonic': '',
  }));

  @action
  void setNewAccount(Map<String, dynamic> acc) {
    for (var k in acc.keys) {
      newAccount[k] = acc[k];
    }

    print('setNewAccount:');
    print(newAccount);
  }
}
