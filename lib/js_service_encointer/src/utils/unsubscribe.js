
export function unsubscribe (unsub, msgChannel) {
  const unsubFuncName = `unsub${msgChannel}`;
  window[unsubFuncName] = unsub;
  return {};
}
