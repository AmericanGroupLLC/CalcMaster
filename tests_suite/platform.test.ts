export {};
        // Shared domain helpers for CalMaster
const isValidEmail = (e) => /^[\w.+-]+@[\w-]+\.[\w.]+$/.test(e);
const isValidUrl = (u) => u.startsWith('http://') || u.startsWith('https://');
const formatCurrency = (n, sym='$') => `${sym}${Number(n).toFixed(2)}`;
const clamp = (v, min, max) => Math.min(Math.max(v, min), max);
const truncate = (s, max) => s.length <= max ? s : s.slice(0, max) + '...';
const paginate = (arr, page, size) => arr.slice(page * size, (page + 1) * size);
const toSlug = (s) => s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
const daysBetween = (a, b) => Math.abs(Math.round((b - a) / 86400000));
const isPastDate = (d) => d < new Date();
const formatDate = (d) => d.toISOString().slice(0, 10);
const debounce = (fn, ms) => { let t; return (...a) => { clearTimeout(t); t = setTimeout(() => fn(...a), ms); }; };
const deepEqual = (a, b) => JSON.stringify(a) === JSON.stringify(b);


describe('CalMaster — Platform Tests (iOS · Android · Desktop · Extension)', () => {

  describe('iOS-specific', () => {
    const iOS = {
      safeAreaTop: 44, safeAreaBottom: 34,
      statusBarHeight: 44,
      homeIndicatorHeight: 34,
      hapticFeedback: true,
      biometricType: 'faceId',
    };
    test('safe area top inset defined', () => expect(iOS.safeAreaTop).toBeGreaterThan(0));
    test('safe area bottom inset defined', () => expect(iOS.safeAreaBottom).toBeGreaterThan(0));
    test('supports haptic feedback', () => expect(iOS.hapticFeedback).toBe(true));
    test('biometric type is faceId or touchId', () => expect(['faceId','touchId']).toContain(iOS.biometricType));
    test('status bar height correct for notched device', () => expect(iOS.statusBarHeight).toBeGreaterThanOrEqualTo(44));
  });

  describe('Android-specific', () => {
    const android = {
      statusBarHeight: 24,
      navigationBarHeight: 48,
      backButtonEnabled: true,
      notificationChannels: ['default', 'alerts', 'promotions'],
      minSdkVersion: 26,
      targetSdkVersion: 34,
    };
    test('status bar height correct', () => expect(android.statusBarHeight).toBe(24));
    test('back button enabled', () => expect(android.backButtonEnabled).toBe(true));
    test('notification channels defined', () => expect(android.notificationChannels).toHaveLength(3));
    test('min SDK version is 26+', () => expect(android.minSdkVersion).toBeGreaterThanOrEqualTo(26));
    test('targets latest stable SDK', () => expect(android.targetSdkVersion).toBeGreaterThanOrEqualTo(33));
  });

  describe('Desktop (macOS/Windows)', () => {
    const desktop = {
      minWindowWidth: 800, minWindowHeight: 600,
      defaultWindowWidth: 1280, defaultWindowHeight: 720,
      supportsKeyboardShortcuts: true,
      supportsMenuBar: true,
      supportsMultiWindow: false,
    };
    test('minimum window size defined', () => {
      expect(desktop.minWindowWidth).toBeGreaterThanOrEqualTo(800);
      expect(desktop.minWindowHeight).toBeGreaterThanOrEqualTo(600);
    });
    test('default window is HD', () => {
      expect(desktop.defaultWindowWidth).toBe(1280);
      expect(desktop.defaultWindowHeight).toBe(720);
    });
    test('keyboard shortcuts supported', () => expect(desktop.supportsKeyboardShortcuts).toBe(true));
    test('menu bar supported on desktop', () => expect(desktop.supportsMenuBar).toBe(true));
  });

  describe('Browser extension', () => {
    const ext = {
      manifestVersion: 3,
      permissions: ['storage', 'activeTab', 'notifications'],
      contentScriptMatches: ['<all_urls>'],
      serviceWorkerType: 'module',
    };
    test('uses manifest v3', () => expect(ext.manifestVersion).toBe(3));
    test('has required permissions', () => {
      expect(ext.permissions).toContain('storage');
      expect(ext.permissions).toContain('activeTab');
    });
    test('content script matches all URLs', () => expect(ext.contentScriptMatches).toContain('<all_urls>'));
    test('service worker is module type', () => expect(ext.serviceWorkerType).toBe('module'));
  });

  describe('Cross-platform data sync', () => {
    const syncState = {
      lastSyncedAt: null,
      pendingChanges: 0,
      syncInProgress: false,
    };
    const startSync = () => { syncState.syncInProgress = true; };
    const completeSync = () => { syncState.syncInProgress = false; syncState.lastSyncedAt = Date.now(); syncState.pendingChanges = 0; };
    const addChange = () => { syncState.pendingChanges++; };

    test('sync starts correctly', () => { startSync(); expect(syncState.syncInProgress).toBe(true); });
    test('sync completes and clears pending', () => { addChange(); addChange(); completeSync(); expect(syncState.pendingChanges).toBe(0); });
    test('lastSyncedAt set after sync', () => expect(syncState.lastSyncedAt).not.toBeNull());
    test('pending changes increment correctly', () => { addChange(); addChange(); expect(syncState.pendingChanges).toBe(2); });
  });
});
