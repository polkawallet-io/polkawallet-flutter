import '../';
import BN from 'bn.js';
import { encodeFloatToI64F64, toI16F16, toI32F32, toI64F64 } from './fixpointUtil';
import { bnToU8a } from '@polkadot/util';
import u8aToHex from '@polkadot/util/u8a/toHex';
import hexToU8a from '@polkadot/util/hex/toU8a';

describe('fixpointUtil', () => {
  describe('toFixPoint', () => {
    it('should parse integer to fixPoint', async () => {
      const result = toI16F16(1);
      expect(result).toEqual(new BN(0x80000000, 2));
    });
    it('should parse 0 to fixPoint', async () => {
      const result = toI16F16(0);
      expect(result).toEqual(new BN(0x0, 2));
    });
    it('should parse 1.1 to fixPoint', async () => {
      const result = toI16F16(1.1);
      expect(result).toBeDefined();
    });

    it('should encode integer to fixPoint', async () => {
      const result = encodeFloatToI64F64(1);
      expect(result).toEqual(new Uint8Array([0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0]));
      expect(hexToU8a(u8aToHex(result))).toEqual(new Uint8Array([0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0]));
    });
    it('should encode 1.1 to fixPoint', async () => {
      const result = encodeFloatToI64F64(1.1);
      expect(result).toEqual(new Uint8Array([0, 160, 153, 153, 153, 153, 153, 25, 1, 0, 0, 0, 0, 0, 0, 0]));
      expect(hexToU8a(u8aToHex(result))).toEqual(new Uint8Array([0, 160, 153, 153, 153, 153, 153, 25, 1, 0, 0, 0, 0, 0, 0, 0]));
    });

    it('should encode 0.1 to fixPoint', async () => {
      const result = encodeFloatToI64F64(0.1);
      expect(result).toEqual(new Uint8Array([0, 154, 153, 153, 153, 153, 153, 25, 0, 0, 0, 0, 0, 0, 0, 0]));
      expect(hexToU8a(u8aToHex(result))).toEqual(new Uint8Array([0, 154, 153, 153, 153, 153, 153, 25, 0, 0, 0, 0, 0, 0, 0, 0]));
    });

    it('should encode parseFloat(0.2) to fixPoint', async () => {
      // this is the way we receive it form dart side. Implicit handling of the '0.2' as string gave encoding errors
      const result = encodeFloatToI64F64(parseFloat('0.2'));
      expect(result).toEqual(new Uint8Array([0, 52, 51, 51, 51, 51, 51, 51, 0, 0, 0, 0, 0, 0, 0, 0]));
      expect(hexToU8a(u8aToHex(result))).toEqual(new Uint8Array([0, 52, 51, 51, 51, 51, 51, 51, 0, 0, 0, 0, 0, 0, 0, 0]));
    });

    // @demyan do you know why this does not work?
    it('should parse location to fixPoint', async () => {
      const location = { lat: 35.48415638, lon: 18.543548584 };
      const resultLat = toI32F32(location.lat);
      expect(resultLat).toBeDefined();
      const resultLon = toI32F32(location.lon);
      expect(resultLon).toBeDefined();
    });
  });
});
