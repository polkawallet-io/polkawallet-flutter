import 'package:mockito/mockito.dart';
import 'package:polka_wallet/utils/localStorage.dart';

class MockLocalStorage extends Mock implements LocalStorage {}

List<Map<String, dynamic>> accList = [
  {
    "name": "test-ggg",
    "address": "1eiq96Y7844qcjkWUqjEibzqTpY5Si6dbFq6ZqZx8DDSWcv",
    "encoded":
        "0x5d30c7a8ac930d4f8086f5b6468f2ce4f8013c6ac8ce2062b5c4cf8fc48c898807ae3a0ceb62a053e68bbe529a6baa0ae3f68a5ebc11cd2713b83e177bcbbd704e366fddaf259dd7c7ea9b858dac245bfa3544f4134c802d0dd8d546c23b12a7253a732db57cbbcb09bcba21a422e2a84518ad679b3ce1e39a57dac72111f194c4d0c6e28dcd33cf029b8a9bb7ca58af46cd72667540c874d0eb6a77ed",
    "pubKey":
        "0x1cc4e46bbd2bb547d93d952c5de12ea7e3a3f3b638551a8eaf35ad086700c00c",
    "encoding": {
      "content": ["pkcs8", "sr25519"],
      "type": "xsalsa20-poly1305",
      "version": "2"
    },
    "meta": {
      "whenCreated": 1590987392804,
      "whenEdited": 1590987392804,
      "name": "ggg"
    },
    "mnemonic":
        'adjust ability hockey august machine empty cargo monster charge plastic snap gather',
    "rawSeed": 'test_seed',
    "memo": null,
    "observation": null
  }
];
Map<String, dynamic> accNew = {
  "name": "test-ttt",
  "address": "158Hhwd6wG84JPTHkX4QuxyZwz7XfMxLa4BRF3c4Ks5giuxs",
  "encoded":
      "0xb49be6cf02d4b199c2d6716b6e9edf819b81f692e09f02ed5cf46f91ba0daf281d01215595f95424a37d52904ff29e9f51ba20c6a554d1ba45f78698b346232c5db86bef04e9c83432df4ee75e62e230ec2071c1a7104b826ceae82d1dfd2f182f16fd906981d3f9da37ae7bb77841532fc65f40ada6cbab6a9ff6470005db88eddcd71ca1aca9f95e9aa20a784616d99c75d8a0b4e444a637b15e2aa2",
  "pubKey":
      "0xb67fe3812b469da5cac180161851120a45b6c6cf13f5be7062874bfa6cec381f",
  "encoding": {
    "content": ["pkcs8", "sr25519"],
    "type": "xsalsa20-poly1305",
    "version": "2"
  },
  "meta": {
    "whenCreated": 1590987506708,
    "whenEdited": 1590987506708,
    "name": "ttt2"
  },
  "mnemonic":
      'new ability hockey august machine empty cargo monster charge plastic snap gather',
  "rawSeed": 'test_seed_new',
  "memo": null,
  "observation": null
};

String currentAccountPubKey = accList[0]['pubKey'];

List<Map<String, dynamic>> contactList = [];

MockLocalStorage getMockLocalStorage() {
  final localStorage = MockLocalStorage();
  when(localStorage.getAccountList()).thenAnswer((_) {
    return Future.value(accList);
  });
  when(localStorage.addAccount(any)).thenAnswer((invocation) {
    accList.add(invocation.positionalArguments[0]);
    return Future.value();
  });
  when(localStorage.removeAccount(any)).thenAnswer((invocation) {
    accList
        .removeWhere((i) => i['pubKey'] == invocation.positionalArguments[0]);
    return Future.value();
  });
  when(localStorage.setCurrentAccount(any)).thenAnswer((invocation) {
    currentAccountPubKey = invocation.positionalArguments[0];
    return Future.value();
  });
  when(localStorage.getCurrentAccount()).thenAnswer((_) {
    return Future.value(currentAccountPubKey);
  });
  when(localStorage.getObject(any)).thenAnswer((_) => Future.value(null));
  when(localStorage.getSeeds(any)).thenAnswer((_) => Future.value({}));
  when(localStorage.getAccountCache(any, any))
      .thenAnswer((_) => Future.value(null));

  when(localStorage.getContactList())
      .thenAnswer((_) => Future.value(contactList));
  when(localStorage.addContact(any)).thenAnswer((invocation) {
    contactList.add(invocation.positionalArguments[0]);
    return Future.value();
  });
  when(localStorage.removeContact(any)).thenAnswer((invocation) {
    contactList
        .removeWhere((i) => i['address'] == invocation.positionalArguments[0]);
    return Future.value();
  });
  when(localStorage.updateContact(any)).thenAnswer((invocation) {
    contactList.removeWhere(
        (i) => i['pubKey'] == invocation.positionalArguments[0]['pubKey']);
    contactList.add(invocation.positionalArguments[0]);
    return Future.value();
  });
  return localStorage;
}
