"use strict";

// 该文件修改自 ./node_modules/@polkadot/util/logger.js
// 在 `npm install` 之后，运行 `$ copy ./logger.js ./node_modules/@polkadot/util/` 命令
// 以替换 @polkadot 依赖库中的 `logger.js` 文件。
// Modified file from ./node_modules/@polkadot/util/logger.js
// Run `$ copy ./logger.js ./node_modules/@polkadot/util/` after `npm install`
// to replace the `logger.js` file in @polkadot dependency.

var _interopRequireDefault = require("@babel/runtime/helpers/interopRequireDefault");

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.format = format;
exports.default = logger;

// var _chalk = _interopRequireDefault(require("chalk"));

var _moment = _interopRequireDefault(require("moment"));

var _bn = _interopRequireDefault(require("./is/bn"));

var _buffer = _interopRequireDefault(require("./is/buffer"));

var _function = _interopRequireDefault(require("./is/function"));

var _object = _interopRequireDefault(require("./is/object"));

var _u8a = _interopRequireDefault(require("./is/u8a"));

var _toHex = _interopRequireDefault(require("./u8a/toHex"));

// Copyright 2017-2019 @polkadot/util authors & contributors
// This software may be modified and distributed under the terms
// of the Apache-2.0 license. See the LICENSE file for details.
const logTo = {
  debug: "log",
  error: "error",
  log: "log",
  warn: "warn"
};
const chalked = {
  debug: "gray",
  error: "gray",
  log: "gray",
  warn: "gray"
}; // eslint-disable-next-line @typescript-eslint/no-explicit-any

function formatObject(value) {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const result = {}; // eslint-disable-next-line @typescript-eslint/no-explicit-any

  return Object.keys(value).reduce((result, key) => {
    // eslint-disable-next-line @typescript-eslint/no-use-before-define
    result[key] = format(value[key]);
    return result;
  }, result);
} // eslint-disable-next-line @typescript-eslint/no-explicit-any

function format(value) {
  if (Array.isArray(value)) {
    return value.map(format);
  }

  if ((0, _bn.default)(value)) {
    return value.toString();
  }

  if ((0, _buffer.default)(value)) {
    return "0x".concat(value.toString("hex"));
  }

  if ((0, _u8a.default)(value)) {
    return (0, _toHex.default)(value);
  }

  if (value && (0, _object.default)(value) && value.constructor === Object) {
    return formatObject(value);
  }

  return value;
}

function apply(log, type, values) {
  if (values.length === 1 && (0, _function.default)(values[0])) {
    const fnResult = values[0]();
    return apply(log, type, Array.isArray(fnResult) ? fnResult : [fnResult]);
  }

  const chalk = value => chalked[log](value);

  console[logTo[log]](
    chalk((0, _moment.default)().format("YYYY-MM-DD HH:mm:ss")),
    chalk(type),
    ...values.map(format)
  );
} // eslint-disable-next-line @typescript-eslint/no-unused-vars

function noop() {} // noop

/**
 * @name Logger
 * @summary Creates a consistent log interface for messages
 * @description
 * Returns a `Logger` that has `.log`, `.error`, `.warn` and `.debug` (controlled with environment `DEBUG=typeA,typeB`) methods. Logging is done with a consistent prefix (type of logger, date) followed by the actual message using the underlying console.
 * @example
 * <BR>
 *
 * ```javascript
 * const l from '@polkadot/util/logger')('test');
 *
 * l.log('blah'); // <date>     TEST: blah
 * ```
 */

function logger(_type) {
  const type = "".concat(_type.toUpperCase(), ":").padStart(16);
  let isDebug;

  try {
    const isTest = process.env.NODE_ENV === "test";
    const debugList = (process.env.DEBUG || "").split(",");
    isDebug = isTest || !!debugList.find(entry => _type.startsWith(entry));
  } catch (error) {
    isDebug = false;
  }

  return {
    debug: isDebug
      ? function() {
          for (
            var _len = arguments.length, values = new Array(_len), _key = 0;
            _key < _len;
            _key++
          ) {
            values[_key] = arguments[_key];
          }

          return apply("debug", type, values);
        }
      : noop,
    error: function error() {
      for (
        var _len2 = arguments.length, values = new Array(_len2), _key2 = 0;
        _key2 < _len2;
        _key2++
      ) {
        values[_key2] = arguments[_key2];
      }

      return apply("error", type, values);
    },
    log: function log() {
      for (
        var _len3 = arguments.length, values = new Array(_len3), _key3 = 0;
        _key3 < _len3;
        _key3++
      ) {
        values[_key3] = arguments[_key3];
      }

      return apply("log", type, values);
    },
    noop,
    warn: function warn() {
      for (
        var _len4 = arguments.length, values = new Array(_len4), _key4 = 0;
        _key4 < _len4;
        _key4++
      ) {
        values[_key4] = arguments[_key4];
      }

      return apply("warn", type, values);
    }
  };
}
