import { unsubscribe } from '../utils/unsubscribe';

/**
 * Mainly debug method introduced to test subscriptions. Subscribes to the timestamp of the last block
 * @param msgChannel channel that the message handler uses on the dart side
 * @returns {Promise<void>}
 */
export async function subscribeTimestamp (msgChannel) {
  await api.query.timestamp.now((moment) => {
    send(msgChannel, moment);
  }).then((unsub) => unsubscribe(unsub, msgChannel));
}

export async function subscribeNewHeads (msgChannel) {
  await api.rpc.chain.subscribeNewHeads((lastHeader) => {
    send(msgChannel, lastHeader);
  }).then((unsub) => unsubscribe(unsub, msgChannel));
}

export default {
  subscribeTimestamp,
  subscribeNewHeads
};
