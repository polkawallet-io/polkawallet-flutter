import 'dart:convert';
import 'dart:math';

import 'package:mobx/mobx.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/utils/format.dart';

part 'assets.g.dart';

class AssetsStore extends _AssetsStore with _$AssetsStore {
  AssetsStore(AccountStore account) : super(account);
}

abstract class _AssetsStore with Store {
  _AssetsStore(this.account);

  AccountStore account;

  @observable
  bool isTxsLoading = true;

  @observable
  bool submitting = false;

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
          return i.destination == account.currentAccount.address;
        case 2:
          return i.sender == account.currentAccount.address;
        default:
          return true;
      }
    }));
  }

  @computed
  ObservableList<Map<String, dynamic>> get balanceHistory {
    List<Map<String, dynamic>> res = List<Map<String, dynamic>>();
    int total = Fmt.balanceInt(balance);
    txs.asMap().forEach((index, i) {
      if (index != 0) {
        TransferData prev = txs[index - 1];
        if (i.sender == account.currentAccount.address) {
          total -= prev.value;
        } else {
          total += prev.value;
        }
        // add transfer fee: 0.02KSM
        total += 20000000000;
      }
      if (blockMap[i.block] != null) {
        res.add({"time": blockMap[i.block].time, "value": total / pow(10, 12)});
      }
    });
    return ObservableList.of(res.reversed);
  }

  @action
  void setTxsLoading(bool isLoading) {
    isTxsLoading = isLoading;
  }

  @action
  void setAccountBalance(String amt) {
    balance = amt;
  }

  @action
  Future<void> clearTxs() async {
    txs.clear();
  }

  @action
  Future<void> addTxs(List ls) async {
    ls.forEach((i) {
      TransferData tx = TransferData.fromJson(i);
      txs.add(tx);
    });
  }

  @action
  void setTxsFilter(int filter) {
    txsFilter = filter;
  }

  @action
  void setBlockMap(String data) {
    jsonDecode(data).forEach((i) {
      if (blockMap[i['id']] == null) {
        blockMap[i['id']] = BlockData.fromJson(i);
      }
    });
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
    block.time = DateTime.fromMillisecondsSinceEpoch(json['timestamp']);
    return block;
  }
}

abstract class _BlockData with Store {
  @observable
  int id = 0;

  @observable
  String hash = '';

  @observable
  DateTime time = DateTime.now();
}
