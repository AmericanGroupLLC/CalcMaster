// CalMaster — Service Worker (background.js)
const API_BASE = 'https://api.americangroupllc.com/v1/calmaster';

chrome.runtime.onInstalled.addListener(() => {
  console.log('CalMaster extension installed');
  chrome.storage.local.set({ initialized: true, version: '1.0.0' });
});

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.type === 'FETCH_DATA') {
    fetch(`${API_BASE}/${message.endpoint}`, {
      headers: { 'Content-Type': 'application/json' }
    })
    .then(r => r.json())
    .then(data => sendResponse({ success: true, data }))
    .catch(err => sendResponse({ success: false, error: err.message }));
    return true; // async
  }
  if (message.type === 'NOTIFY') {
    chrome.notifications.create({
      type: 'basic',
      iconUrl: 'icons/icon48.png',
      title: 'CalMaster',
      message: message.text
    });
  }
});

// Periodic sync every 30 minutes
chrome.alarms.create('sync', { periodInMinutes: 30 });
chrome.alarms.onAlarm.addListener(alarm => {
  if (alarm.name === 'sync') {
    chrome.storage.local.get('lastSync', (data) => {
      chrome.storage.local.set({ lastSync: Date.now() });
    });
  }
});
