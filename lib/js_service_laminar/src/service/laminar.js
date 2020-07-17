async function subscribeMessage(section, method, params, msgChannel) {
  const s = laminarApi[section][method](...params).subscribe((res) => {
    send(msgChannel, res);
  });
  const unsubFuncName = `unsub${msgChannel}`;
  window[unsubFuncName] = s.unsubscribe;
  return {};
}

export default {
  subscribeMessage,
};
