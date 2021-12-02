import settings from '../../src/service/settings';
import { JSDOM } from 'jsdom';

/***
 * Initialize the global window the same as when running in an actual browser.
 */
export function setGlobalWindow () {
  const { window } = new JSDOM();
  global.window = window;

  global.window.send = (_, data) => console.log(data);
}

/***
 * Initialize the global window and connect to a `network`.
 */
export async function testSetup (network) {
  setGlobalWindow();

  const configOverrides = {
    types: network.customTypes,
    pallets: network.palletOverrides,
  };

  await settings.connect(network.chain, configOverrides);

  global.api = global.window.api;

  return {
    window: global.window,
    api: global.api,
  };
}
