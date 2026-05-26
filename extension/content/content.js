// Content script: minimal footprint — only listens for messages from background
chrome.runtime.onMessage.addListener((msg, sender, sendResponse) => {
  if (msg.type === 'CALC_RESULT') {
    // Could show an inline tooltip with the result in the future
    sendResponse({ ok: true });
  }
});
