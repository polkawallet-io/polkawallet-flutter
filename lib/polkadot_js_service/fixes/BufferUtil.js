/*!
 * Copied from:
 * ws: a node.js websocket client
 * Copyright(c) 2011 Einar Otto Stangvik <einaros@gmail.com>
 * MIT Licensed
 */

// 该文件修改自 ../node_modules/websocket/lib/BufferUtil.js
// 在 `npm install` 之后，运行 `$ copy ./BufferUtil.js ../node_modules/websocket/lib/` 命令
// 以替换依赖库中的文件。
// Modified file from ../node_modules/websocket/lib/BufferUtil.js
// Run `$ copy ./BufferUtil.js ../node_modules/websocket/lib/` after `npm install`
// to replace the `BufferUtil.js` file in dependency.

try {
  module.exports = require("./BufferUtil.fallback");
} catch (e) {
  console.error(
    "bufferutil.node seems to not have been built. Run npm install."
  );
  throw e;
}
