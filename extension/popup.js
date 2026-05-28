// CalMaster — Popup Script
document.addEventListener('DOMContentLoaded', () => {
  const openBtn = document.getElementById('openApp');
  const notifBtn = document.getElementById('toggleNotif');

  chrome.storage.local.get(['notificationsEnabled'], (data) => {
    notifBtn.textContent = data.notificationsEnabled ? 'Disable Notifications' : 'Enable Notifications';
  });

  openBtn.addEventListener('click', () => {
    chrome.tabs.create({ url: 'https://americangroupllc.com/calmaster' });
  });

  notifBtn.addEventListener('click', () => {
    chrome.storage.local.get(['notificationsEnabled'], (data) => {
      const enabled = !data.notificationsEnabled;
      chrome.storage.local.set({ notificationsEnabled: enabled });
      notifBtn.textContent = enabled ? 'Disable Notifications' : 'Enable Notifications';
      chrome.runtime.sendMessage({
        type: 'NOTIFY',
        text: enabled ? 'Notifications enabled for CalMaster' : 'Notifications disabled'
      });
    });
  });
});
