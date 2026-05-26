// CalcMaster extension options page script
// Extracted from inline script to comply with Manifest V3 CSP (no inline scripts).
const defaultTab = document.getElementById('default-tab');
const defaultCat = document.getElementById('default-category');
const savedMsg = document.getElementById('saved-msg');

chrome.storage.local.get(['defaultTab', 'defaultCategory'], (data) => {
  if (data.defaultTab) defaultTab.value = data.defaultTab;
  if (data.defaultCategory) defaultCat.value = data.defaultCategory;
});

function save() {
  chrome.storage.local.set({
    defaultTab: defaultTab.value,
    defaultCategory: defaultCat.value
  });
  savedMsg.classList.add('show');
  setTimeout(() => savedMsg.classList.remove('show'), 2000);
}

defaultTab.addEventListener('change', save);
defaultCat.addEventListener('change', save);
