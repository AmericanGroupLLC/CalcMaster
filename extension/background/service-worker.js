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
    // NOTE: Function() / eval is forbidden in MV3 service workers.
    // We send the selected text to the popup for safe evaluation instead.
    chrome.storage.local.set({ pendingCalculate: text });
    chrome.action.openPopup();
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
