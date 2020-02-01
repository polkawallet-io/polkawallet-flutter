import 'package:mobx/mobx.dart';

part 'assets.g.dart';

class AssetsState extends _AssetsState with _$AssetsState {}

abstract class _AssetsState with Store {
  @observable
  String balance = '0';

  @observable
  ObservableList<TransferData> txs = ObservableList<TransferData>();

  @observable
  TransferData txDetail = TransferData();
}

class TransferData extends _TransferData with _$TransferData {}

abstract class _TransferData with Store {
  @observable
  String type = '';

  @observable
  String id = '';

  @observable
  String sender = '';

  @observable
  String senderId = '';

  @observable
  String destination = '';

  @observable
  String destinationId = '';

  @observable
  int value = 0;

  @observable
  int fee = 0;
}
