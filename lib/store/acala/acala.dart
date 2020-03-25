import 'package:mobx/mobx.dart';
import 'package:polka_wallet/store/account.dart';

part 'acala.g.dart';

class AcalaStore = _AcalaStore with _$AcalaStore;

abstract class _AcalaStore with Store {
  @observable
  AccountStore account = AccountStore();
}
