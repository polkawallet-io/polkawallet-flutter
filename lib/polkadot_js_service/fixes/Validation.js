/*!
 * UTF-8 Validation Code originally from:
 * ws: a node.js websocket client
 * Copyright(c) 2011 Einar Otto Stangvik <einaros@gmail.com>
 * MIT Licensed
 */

// 该文件修改自 ../node_modules/websocket/lib/Validation.js
// 在 `npm install` 之后，运行 `$ copy ./Validation.js ../node_modules/websocket/lib/` 命令
// 以替换依赖库中的文件。
// Modified file from ../node_modules/websocket/lib/Validation.js
// Run `$ copy ./Validation.js ../node_modules/websocket/lib/` after `npm install`
// to replace the `Validation.js` file in dependency.

try {
  module.exports = require("./Validation.fallback");
} catch (e) {
  console.error(
    "validation.node seems not to have been built. Run npm install."
  );
  throw e;
}
