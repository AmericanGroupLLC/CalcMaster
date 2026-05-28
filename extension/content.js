// CalMaster — Content Script (content.js)
(() => {
  'use strict';
  const APP_NAME = 'CalMaster';

  function init() {
    // Inject floating action button
    if (document.getElementById('calmaster-fab')) return;
    const fab = document.createElement('div');
    fab.id = 'calmaster-fab';
    fab.style.cssText = `
      position: fixed; bottom: 24px; right: 24px; z-index: 999999;
      width: 48px; height: 48px; border-radius: 50%;
      background: #37474F; cursor: pointer;
      box-shadow: 0 4px 12px rgba(0,0,0,0.3);
      display: flex; align-items: center; justify-content: center;
      transition: transform 0.2s ease;
    `;
    fab.innerHTML = '<span style="color:white;font-size:20px;font-weight:bold">C</span>';
    fab.addEventListener('mouseenter', () => fab.style.transform = 'scale(1.1)');
    fab.addEventListener('mouseleave', () => fab.style.transform = 'scale(1)');
    fab.addEventListener('click', () => {
      chrome.runtime.sendMessage({ type: 'OPEN_POPUP' });
    });
    document.body.appendChild(fab);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
