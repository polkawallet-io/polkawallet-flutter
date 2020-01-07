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
    'address': '',
    'seed': '',
    'isLocked': false,
    'mnemonic': '',
  }));

  @action
  void setNewAccount(Map<String, dynamic> res) {
    Map<String, dynamic> acc = Map<String, dynamic>.from(res['data']);

    for (var k in acc.keys) {
      newAccount[k] = acc[k];
    }
  }
}
