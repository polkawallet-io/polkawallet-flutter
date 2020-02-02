import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';

part 'assets.g.dart';

class AssetsState extends _AssetsState with _$AssetsState {}

abstract class _AssetsState with Store {
  @observable
  String address = '';

  @observable
  String balance = '0';

  @observable
  ObservableList<TransferData> txs = ObservableList<TransferData>();

  @observable
  int txsFilter = 0;

  @observable
  TransferData txDetail = TransferData();

  @observable
  ObservableMap<String, BlockData> blockMap =
      ObservableMap<String, BlockData>();

  @computed
  ObservableList<TransferData> get txsView {
    return ObservableList.of(txs.where((i) {
      switch (txsFilter) {
        case 1:
          return i.destination == address;
        case 2:
          return i.sender == address;
        default:
          return true;
      }
    }));
  }
}

class TransferData extends _TransferData with _$TransferData {
  static TransferData fromJson(Map<String, dynamic> json) {
    TransferData tx = TransferData();
    tx.type = json['type'];
    tx.id = json['id'];
    tx.value = json['attributes']['value'];
    tx.fee = json['attributes']['fee'];
    tx.sender = json['attributes']['sender']['attributes']['address'];
    tx.senderId = json['attributes']['sender']['attributes']['index_address'];
    tx.destination = json['attributes']['destination']['attributes']['address'];
    tx.destinationId =
        json['attributes']['destination']['attributes']['index_address'];
    return tx;
  }
}

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

@JsonSerializable()
class BlockData extends _BlockData with _$BlockData {
  static BlockData fromJson(Map<String, dynamic> json) =>
      _$BlockDataFromJson(json);
}

abstract class _BlockData with Store {
  @observable
  int id = 0;

  @observable
  String hash = '';

  @observable
  String datetime = '';
}
