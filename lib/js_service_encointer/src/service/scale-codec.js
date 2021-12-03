import { u8aToU8a } from '@polkadot/util';

/**
 * Decode given data into type. The type must be registered in the api's type registry.
 *
 * Data can be either a hex-string or a Uint8Array. If the json-representation is passed, this function is a no-op.
 *
 * @param {string} type
 * @param {unknown} data
 */
export async function decode (type, data) {
  return api.createType(type, u8aToU8a(data));
}

/**
 * Encode the given object of type to a Uint8Array. The type must be registered in the api's type registry.
 *
 * Most likely, the object will be a hex-string or json-representation of the object. If a Uint8Array is passed, this
 * function is a no-op.
 *
 * @param {string} type
 * @param {unknown} object
 */
export async function encode (type, object) {
  return api.createType(type, object).toU8a();
}

/**
 * Encode the given object of type to a hex-string. The type must be registered in the api's type registry.
 *
 * Most likely, the object will be a Uint8Array or json-representation of the object. If a hex-string is passed, this
 * function is a no-op.
 *
 * @param {string} type
 * @param {unknown} object
 */
export async function encodeToHex (type, object) {
  return api.createType(type, object).toHex();
}

export default {
  decode,
  encode,
  encodeToHex
};
