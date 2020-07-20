import {
  compactFromU8a,
  hexStripPrefix,
  hexToU8a,
  u8aConcat,
  u8aToHex,
  u8aToU8a,
} from "@polkadot/util";
import {
  encodeAddress,
  decodeAddress,
  blake2AsU8a,
} from "@polkadot/util-crypto";
import { SUBSTRATE_NETWORK_LIST } from "../constants/networkSpect";

const MULTIPART = new Uint8Array([0]);

let signer = {};
let submittable = {};

/*
  Example Full Raw Data
  ---
  4 // indicates binary
  37 // indicates data length
  --- UOS Specific Data
  00 + // is it multipart?
  0001 + // how many parts in total?
  0000 +  // which frame are we on?
  53 // indicates payload is for Substrate
  01 // crypto: sr25519
  00 // indicates action: signData
  f4cd755672a8f9542ca9da4fbf2182e79135d94304002e6a09ffc96fef6e6c4c // public key
  544849532049532053504152544121 // actual payload to sign (should be SCALE or utf8)
  91b171bb158e2d3848fa23a9f1c25182fb8e20313b2c1eb49219da7a70ce90c3 // genesis hash
  0 // terminator
  --- SQRC Filler Bytes
  ec11ec11ec11ec // SQRC filler bytes
  */
function _rawDataToU8A(rawData) {
  if (!rawData) {
    return null;
  }

  // Strip filler bytes padding at the end
  if (rawData.substr(-2) === "ec") {
    rawData = rawData.substr(0, rawData.length - 2);
  }

  while (rawData.substr(-4) === "ec11") {
    rawData = rawData.substr(0, rawData.length - 4);
  }

  // Verify that the QR encoding is binary and it's ending with a proper terminator
  if (rawData.substr(0, 1) !== "4" || rawData.substr(-1) !== "0") {
    return null;
  }

  // Strip the encoding indicator and terminator for ease of reading
  rawData = rawData.substr(1, rawData.length - 2);

  const length8 = parseInt(rawData.substr(0, 2), 16) || 0;
  const length16 = parseInt(rawData.substr(0, 4), 16) || 0;
  let length = 0;

  // Strip length prefix
  if (length8 * 2 + 2 === rawData.length) {
    rawData = rawData.substr(2);
    length = length8;
  } else if (length16 * 2 + 4 === rawData.length) {
    rawData = rawData.substr(4);
    length = length16;
  } else {
    return null;
  }

  const bytes = new Uint8Array(length);

  for (let i = 0; i < length; i++) {
    bytes[i] = parseInt(rawData.substr(i * 2, 2), 16);
  }

  return bytes;
}

async function _constructDataFromBytes(bytes, multipartComplete = false) {
  const frameInfo = hexStripPrefix(u8aToHex(bytes.slice(0, 5)));
  const frameCount = parseInt(frameInfo.substr(2, 4), 16);
  const isMultipart = frameCount > 1; // for simplicity, even single frame payloads are marked as multipart.
  const currentFrame = parseInt(frameInfo.substr(6, 4), 16);
  const uosAfterFrames = hexStripPrefix(u8aToHex(bytes.slice(5)));

  // UOS after frames can be metadata json
  if (isMultipart && !multipartComplete) {
    const partData = {
      currentFrame,
      frameCount,
      isMultipart,
      partData: uosAfterFrames,
    };
    return partData;
  }

  const zerothByte = uosAfterFrames.substr(0, 2);
  const firstByte = uosAfterFrames.substr(2, 2);
  const secondByte = uosAfterFrames.substr(4, 2);

  let action;

  try {
    // decode payload appropriately via UOS
    switch (zerothByte) {
      case "45": {
        // Ethereum UOS payload
        const data = {
          data: {}, // for consistency with legacy data format.
        };
        action =
          firstByte === "00" || firstByte === "01"
            ? "signData"
            : firstByte === "01"
            ? "signTransaction"
            : null;
        const address = uosAfterFrames.substr(4, 44);

        data.action = action;
        data.data.account = address;
        if (action === "signData") {
          data.data.rlp = uosAfterFrames[13];
        } else if (action === "signTransaction") {
          data.data.data = uosAfterFrames[13];
        } else {
          throw new Error("Could not determine action type.");
        }
        return data;
      }
      case "53": {
        // Substrate UOS payload
        const data = {
          data: {}, // for consistency with legacy data format.
        };
        try {
          data.data.crypto =
            firstByte === "00"
              ? "ed25519"
              : firstByte === "01"
              ? "sr25519"
              : null;
          const pubKeyHex = uosAfterFrames.substr(6, 64);
          const publicKeyAsBytes = hexToU8a("0x" + pubKeyHex);
          const hexEncodedData = "0x" + uosAfterFrames.slice(70);
          const hexPayload = hexEncodedData.slice(0, -64);
          const genesisHash = `0x${hexEncodedData.substr(-64)}`;
          const rawPayload = hexToU8a(hexPayload);
          data.data.genesisHash = genesisHash;
          const isOversized = rawPayload.length > 256;
          const network = SUBSTRATE_NETWORK_LIST[genesisHash];
          if (!network) {
            throw new Error(
              `Signer does not currently support a chain with genesis hash: ${genesisHash}`
            );
          }

          switch (secondByte) {
            case "00": // sign mortal extrinsic
            case "02": // sign immortal extrinsic
              data.action = isOversized ? "signData" : "signTransaction";
              data.oversized = isOversized;
              data.isHash = isOversized;
              const [offset] = compactFromU8a(rawPayload);
              const payload = rawPayload.subarray(offset);
              // data.data.data = isOversized
              // 	? await blake2b(u8aToHex(payload, -1, false))
              // 	: rawPayload;
              data.data.data = rawPayload; // ignore oversized data for now
              data.data.account = encodeAddress(
                publicKeyAsBytes,
                network.prefix
              ); // encode to the prefix;

              break;
            case "01": // data is a hash
              data.action = "signData";
              data.oversized = false;
              data.isHash = true;
              data.data.data = hexPayload;
              data.data.account = encodeAddress(
                publicKeyAsBytes,
                network.prefix
              ); // default to Kusama
              break;
          }
        } catch (e) {
          throw new Error(
            "Error: something went wrong decoding the Substrate UOS payload: " +
              uosAfterFrames
          );
        }
        return data;
      }
      default:
        throw new Error("Error: Payload is not formatted correctly: " + bytes);
    }
  } catch (e) {
    throw new Error("we cannot handle the payload: " + bytes);
  }
}

function _isMultipartData(parsedData) {
  const hasMultiFrames =
    parsedData.frameCount !== undefined && parsedData.frameCount > 1;
  return parsedData.isMultipart || hasMultiFrames;
}

async function _setPartData(currentFrame, frameCount, partData) {
  // set it once only
  if (!signer.totalFrameCount) {
    const newArray = new Array(frameCount).fill(null);
    signer.multipartData = newArray;
    signer.totalFrameCount = frameCount;
  }
  const {
    completedFramesCount,
    multipartComplete,
    multipartData,
    totalFrameCount,
  } = signer;
  const partDataAsBytes = new Uint8Array(partData.length / 2);

  for (let i = 0; i < partDataAsBytes.length; i++) {
    partDataAsBytes[i] = parseInt(partData.substr(i * 2, 2), 16);
  }

  if (
    currentFrame === 0 &&
    (partDataAsBytes[0] === new Uint8Array([0x00])[0] ||
      partDataAsBytes[0] === new Uint8Array([0x7b])[0])
  ) {
    // part_data for frame 0 MUST NOT begin with byte 00 or byte 7B.
    throw new Error("Error decoding invalid part data.");
  }
  if (completedFramesCount < totalFrameCount) {
    // we haven't filled all the frames yet
    const nextDataState = multipartData;
    nextDataState[currentFrame] = partDataAsBytes;

    const nextMissedFrames = nextDataState.reduce((acc, current, index) => {
      if (current === null) acc.push(index + 1);
      return acc;
    }, []);
    const nextCompletedFramesCount = totalFrameCount - nextMissedFrames.length;
    signer.completedFramesCount = nextCompletedFramesCount;
    signer.latestFrame = currentFrame;
    signer.missedFrames = nextMissedFrames;
    signer.multipartData = nextDataState;

    if (
      totalFrameCount > 0 &&
      nextCompletedFramesCount === totalFrameCount &&
      !multipartComplete
    ) {
      // all the frames are filled
      await _integrateMultiPartData();
    }
  }
}

async function _integrateMultiPartData() {
  const { multipartData, totalFrameCount } = signer;

  // concatenate all the parts into one binary blob
  let concatMultipartData = multipartData.reduce((acc, part) => {
    if (part === null) throw new Error("part data is not completed");
    const c = new Uint8Array(acc.length + part.length);
    c.set(acc);
    c.set(part, acc.length);
    return c;
  }, new Uint8Array(0));

  // unshift the frame info
  const frameInfo = u8aConcat(
    MULTIPART,
    _encodeNumber(totalFrameCount),
    _encodeNumber(0)
  );
  concatMultipartData = u8aConcat(frameInfo, concatMultipartData);

  signer.multipartComplete = true;
  // handle the binary blob as a single UOS payload
  await _setParsedData(concatMultipartData, true);
}

function _encodeNumber(value) {
  return new Uint8Array([value >> 8, value & 0xff]);
}

async function _setParsedData(strippedData, multipartComplete = false) {
  const parsedData = await _constructDataFromBytes(
    strippedData,
    multipartComplete
  );
  if (_isMultipartData(parsedData)) {
    await _setPartData(
      parsedData.currentFrame,
      parsedData.frameCount,
      parsedData.partData
    );
    return;
  }

  signer.unsignedData = parsedData;
}

export async function parseQrCode(rawData) {
  signer = {};
  try {
    const strippedData = _rawDataToU8A(rawData);
    await _setParsedData(strippedData, false);
    return { signer: signer.unsignedData.data.account };
  } catch (err) {
    return { error: err.message };
  }
}

export function getSigner() {
  return signer;
}

const CMD_HASH = 1;
const CMD_MORTAL = 2;

export function makeTx(txInfo, paramList) {
  return new Promise((resolve) => {
    const signer = txInfo.proxy
      ? encodeAddress(hexToU8a(txInfo.proxy), parseInt(txInfo.ss58))
      : txInfo.address;
    api.derive.tx
      .signingInfo(signer)
      .then(({ header, mortalLength, nonce }) => {
        let tx = api.tx[txInfo.module][txInfo.call](...paramList);
        if (txInfo.proxy) {
          tx = api.tx.recovery.asRecovered(txInfo.address, tx);
        }
        const signerPayload = api.registry.createType("SignerPayload", {
          address: signer,
          blockHash: header.hash,
          blockNumber: header ? header.number : 0,
          era: api.api.registry.createType("ExtrinsicEra", {
            current: header.number,
            period: mortalLength,
          }),
          genesisHash: api.genesisHash,
          method: tx.method,
          nonce,
          signedExtensions: ["CheckNonce"],
          tip: txInfo.tip,
          runtimeVersion: {
            specVersion: api.runtimeVersion.specVersion,
            transactionVersion: api.runtimeVersion.transactionVersion,
          },
          version: api.extrinsicVersion,
        });
        const payload = signerPayload.toPayload();

        // limit size of the transaction
        const qrIsHashed = payload.method.length > 5000;
        const wrapper = api.registry.createType("ExtrinsicPayload", payload, {
          version: payload.version,
        });
        const qrPayload = qrIsHashed
          ? blake2AsU8a(wrapper.toU8a(true))
          : wrapper.toU8a();
        // cache this submittableExtrinsic
        submittable = { tx, payload: signerPayload.toPayload(), paramList };
        resolve({
          qrAddress: payload.address,
          qrIsHashed,
          qrPayload: _createFrames(
            _createSignPayload(
              payload.address,
              qrIsHashed ? CMD_HASH : CMD_MORTAL,
              qrPayload,
              api.genesisHash
            )
          )[0],
        });
      })
      .catch((err) => resolve({ error: err.message }));
  });
}

const SUBSTRATE_ID = new Uint8Array([0x53]);
const CRYPTO_SR25519 = new Uint8Array([0x01]);
const FRAME_SIZE = 1024;

function _createSignPayload(address, cmd, payload, genesisHash) {
  return u8aConcat(
    SUBSTRATE_ID,
    CRYPTO_SR25519,
    new Uint8Array([cmd]),
    decodeAddress(address),
    u8aToU8a(payload),
    u8aToU8a(genesisHash)
  );
}

function _createFrames(input) {
  const frames = [];
  let idx = 0;
  while (idx < input.length) {
    frames.push(input.subarray(idx, idx + FRAME_SIZE));
    idx += FRAME_SIZE;
  }
  return frames.map((frame, index) =>
    u8aConcat(
      MULTIPART,
      _encodeNumber(frames.length),
      _encodeNumber(index),
      frame
    )
  );
}

export function getSubmittable() {
  return submittable;
}
