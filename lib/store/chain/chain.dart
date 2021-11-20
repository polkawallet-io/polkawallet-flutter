import 'package:encointer_wallet/store/app.dart';
import 'package:mobx/mobx.dart';
import 'package:encointer_wallet/store/chain/types/header.dart';

part 'chain.g.dart';

class ChainStore extends _ChainStore with _$ChainStore {
  ChainStore(AppStore store) : super(store);
}

abstract class _ChainStore with Store {
  _ChainStore(this.rootStore);

  final AppStore rootStore;

  final String latestHeaderKey = 'chain_latest_header';

  @observable
  Header latestHeader;

  @action
  void setLatestHeader(Header latest) {
    latestHeader = latest;
    rootStore.cacheObject(latestHeaderKey, latest);
  }

  @computed
  get latestHeaderNumber => latestHeader?.number;

  Future<void> loadCache() async {
    Map h = await rootStore.loadObject(latestHeaderKey);
    if (h != null) {
      latestHeader = Header.fromJson(h);
    }
  }
}
