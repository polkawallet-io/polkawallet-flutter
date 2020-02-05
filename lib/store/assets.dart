import 'dart:convert';

import 'package:mobx/mobx.dart';
import 'package:polka_wallet/service/polkascan.dart';
import 'package:polka_wallet/utils/format.dart';

part 'assets.g.dart';

class AssetsState extends _AssetsState with _$AssetsState {}

abstract class _AssetsState with Store {
  @observable
  bool loading = false;

  @observable
  bool submitting = false;

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
  ObservableMap<int, BlockData> blockMap = ObservableMap<int, BlockData>();

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

  @action
  void setAccountBalance(String amt) {
    balance = amt;
  }

  @action
  Future<List<int>> getTxs(String address) async {
    if (!Fmt.isAddress(address)) {
      txs.clear();
      return [];
    }

    loading = true;
    String data = await PolkaScanApi.fetchTxs(address);
    List<dynamic> ls = jsonDecode(data)['data'];
    txs.clear();
    ls.forEach((i) {
      TransferData tx = TransferData.fromJson(i);
      txs.add(tx);
    });
    return txs.map((i) => i.block).toList();
  }

  @action
  void setTxsFilter(int filter) {
    txsFilter = filter;
  }

  @action
  Future<void> setBlockMap(String data) async {
    jsonDecode(data).forEach((i) {
      if (blockMap[i['id']] == null) {
        blockMap[i['id']] = BlockData.fromJson(i);
      }
    });
    loading = false;
  }

  @action
  void setTxDetail(TransferData tx) {
    txDetail = tx;
  }

  @action
  void setSubmitting(bool isSubmitting) {
    submitting = isSubmitting;
  }
}

class TransferData extends _TransferData with _$TransferData {
  static TransferData fromJson(Map<String, dynamic> json) {
    TransferData tx = TransferData();
    tx.type = json['type'];
    tx.id = json['id'];
    tx.block = json['attributes']['block_id'];
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
  int block = 0;

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

class BlockData extends _BlockData with _$BlockData {
  static BlockData fromJson(Map<String, dynamic> json) {
    BlockData block = BlockData();
    block.id = json['id'];
    block.hash = json['hash'];
    block.time = DateTime.fromMillisecondsSinceEpoch(json['timestamp'])
        .toString()
        .split('.')[0];
    return block;
  }
}

abstract class _BlockData with Store {
  @observable
  int id = 0;

  @observable
  String hash = '';

  @observable
  String time = '';
}
