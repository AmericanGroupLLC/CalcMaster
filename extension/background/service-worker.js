chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.create({
    id: 'calcmaster-convert',
    title: 'Convert with CalcMaster',
    contexts: ['selection']
  });
  chrome.contextMenus.create({
    id: 'calcmaster-calculate',
    title: 'Calculate with CalcMaster',
    contexts: ['selection']
  });
});

chrome.contextMenus.onClicked.addListener((info, tab) => {
  if (!info.selectionText) return;
  const text = info.selectionText.trim();

  if (info.menuItemId === 'calcmaster-calculate') {
    try {
      const safe = text.replace(/[^0-9+\-*/.()%]/g, '');
      if (safe.length > 0) {
        const result = Function('"use strict"; return (' + safe + ')')();
        if (isFinite(result)) {
          chrome.action.setBadgeText({ text: String(result).slice(0, 4) });
          chrome.action.setBadgeBackgroundColor({ color: '#7C5CFF' });
          setTimeout(() => chrome.action.setBadgeText({ text: '' }), 5000);
        }
      }
    } catch { /* not a valid expression */ }
  }

  if (info.menuItemId === 'calcmaster-convert') {
    chrome.storage.local.set({ pendingConvert: text });
    chrome.action.openPopup();
  }
});

chrome.commands?.onCommand?.addListener((command) => {
  if (command === 'open-calculator') {
    chrome.action.openPopup();
  }
});
