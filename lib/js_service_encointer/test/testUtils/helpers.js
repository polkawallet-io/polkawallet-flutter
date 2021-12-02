import { createType } from '@polkadot/types';
import { bs58 } from '@polkadot/util-crypto/base58/bs58';
import { createTrustedCall } from '../../src/service/account';

export function getTrustedCall (sender, registry, network) {
  const cidTyped = createType(registry, 'CommunityIdentifier', bs58.decode(network.chosenCid));
  const mrenclave = createType(registry, 'Hash', bs58.decode(network.mrenclave));
  const nonce = createType(registry, 'u32', 0);
  const proof = createType(registry, 'Option<ProofOfAttendance<MultiSignature, AccountId>>');

  return createTrustedCall(
    sender,
    cidTyped,
    mrenclave,
    nonce,
    'ceremonies_register_participant',
    [sender.publicKey, cidTyped, proof]
  );
}
