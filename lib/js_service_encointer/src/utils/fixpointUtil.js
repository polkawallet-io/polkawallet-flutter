import BN from 'bn.js';
import assert from 'assert';
import bnToU8a from '@polkadot/util/bn/toU8a';

const assertLength = (upper, lower) => {
  const len = upper + lower;
  assert(len >= 8, `Bit length can't be less than 8, provided ${len}`);
  assert(len <= 128, `Bit length can't be bigger than 128, provided ${len}`);
  assert(!(len & (len - 1)), `Bit length should be power of 2, provided ${len}`);
  return len;
};

/// Function to produce function to convert fixed-point to Number
///
/// Fixed interpretation of u<N> place values
/// ... ___ ___ ___ ___ . ___ ___ ___ ___ ...
/// ...  8   4   2   1    1/2 1/4 1/8 1/16...
///
/// Parameters:
/// upper: 0..128 - number of bits in decimal part
/// lower: 0..128 - number of bits in fractional part
///
/// Produced function parameters:
/// raw: substrate_fixed::types::I<upper>F<lower> as I<upper+lower>
/// precision: 0..lower number bits in fractional part to process
export function parserFixPoint (upper, lower) {
  const len = assertLength(upper, lower);
  return (raw, precision = lower) => {
    assert(raw.bitLength() <= len, 'Bit length is not equal to ' + len);
    const bits = raw.toString(2, len);
    const lowerBits = (lower > bits.length
      ? bits.padStart(lower, '0')
      : bits).slice(-lower, -1 * (lower - precision) || undefined);
    const floatPart = lowerBits
      .split('')
      .reduce((acc, bit, idx) => {
        acc = acc + (bit === '1' ? 1 / 2 ** (idx + 1) : 0);
        return acc;
      }, 0);
    const upperBits = bits.slice(0, -lower);
    const decimalPart = upperBits ? parseInt(upperBits, 2) : 0;
    return decimalPart + (raw.negative ? -floatPart : floatPart);
  };
}

export function toFixPoint (upper, lower) {
  assertLength(upper, lower);
  return (num) => {
    const [upperBits, lowerBits] = num.toString(2).split('.');
    assert(upperBits.length <= upper, 'Number is larger than maximum in '.concat(upper, 'bit'));
    if (lowerBits !== undefined) {
      const bits = upperBits.concat(lowerBits.length > lower ? lowerBits.substr(0, lower) : lowerBits.padEnd(lower, '0'));
      return new BN(bits, 2);
    } else {
      const bits = upperBits.padEnd(upper + lower, 0);
      return new BN(bits, 2);
    }
  };
}

export function encodeFloatToFixPoint (upper, lower) {
  assertLength(upper, lower);
  return (num) => {
    const [upperBits, lowerBits] = num.toString(2).split('.');
    assert(upperBits.length <= upper, 'Number is larger than maximum in '.concat(upper, 'bit'));
    if (lowerBits !== undefined) {
      const lowerPadded = lowerBits.length > lower ? lowerBits.substr(0, lower) : lowerBits.padEnd(lower, '0');
      const upperPadded = upperBits.padStart(upper, '0');
      const upperBN = bnToU8a(new BN(upperPadded, 2), upper, true);
      const lowerBN = bnToU8a(new BN(lowerPadded, 2), lower, true);
      return Uint8Array.from([...lowerBN, ...upperBN]);
    } else {
      const bits = upperBits.padStart(upper, '0').padEnd(lower + upper, '0');
      return bnToU8a(new BN(bits, 2), lower + upper, true);
    }
  };
}

export const parseI4F4 = parserFixPoint(4, 4);

export const parseI8F8 = parserFixPoint(8, 8);

export const parseI16F16 = parserFixPoint(16, 16);

export const parseI32F32 = parserFixPoint(32, 32);

export const parseI64F64 = parserFixPoint(64, 64);

export const toI16F16 = toFixPoint(16, 16);

export const toI32F32 = toFixPoint(32, 32);

export const toI64F64 = toFixPoint(64, 64);

export const encodeFloatToI4F4 = encodeFloatToFixPoint(4, 4);

export const encodeFloatToI8F8 = encodeFloatToFixPoint(8, 8);

export const encodeFloatToI16F16 = encodeFloatToFixPoint(16, 16);

export const encodeFloatToI32F32 = encodeFloatToFixPoint(32, 32);

export const encodeFloatToI64F64 = encodeFloatToFixPoint(64, 64);
