// CalMaster — Electron Desktop Tests
const fs = require('fs'), path = require('path');

describe('CalMaster Desktop App', () => {

  describe('package.json', () => {
    let pkg;
    beforeAll(() => { pkg = JSON.parse(fs.readFileSync(path.join(__dirname, 'package.json'), 'utf8')); });
    test('has name', () => expect(pkg.name).toBeDefined());
    test('has version', () => expect(pkg.version).toMatch(/^\d+\.\d+\.\d+$/));
    test('main is main.js', () => expect(pkg.main).toBe('main.js'));
    test('has start script', () => expect(pkg.scripts?.start).toContain('electron'));
    test('has build script', () => expect(pkg.scripts?.build).toContain('electron-builder'));
    test('has electron dependency', () => expect(pkg.dependencies?.electron).toBeDefined());
    test('has mac build config', () => expect(pkg.build?.mac).toBeDefined());
    test('has win build config', () => expect(pkg.build?.win).toBeDefined());
    test('has linux build config', () => expect(pkg.build?.linux).toBeDefined());
    test('appId contains app name', () => expect(pkg.build?.appId).toContain('calmaster'));
  });

  describe('main.js', () => {
    let main;
    beforeAll(() => { main = fs.readFileSync(path.join(__dirname, 'main.js'), 'utf8'); });
    test('creates BrowserWindow', () => expect(main).toContain('BrowserWindow'));
    test('sets minimum window size', () => expect(main).toContain('minWidth'));
    test('loads web URL', () => expect(main).toContain('americangroupllc.com'));
    test('handles window-all-closed', () => expect(main).toContain('window-all-closed'));
    test('uses context isolation', () => expect(main).toContain('contextIsolation: true'));
    test('disables node integration', () => expect(main).toContain('nodeIntegration: false'));
    test('uses preload script', () => expect(main).toContain('preload.js'));
    test('builds native menu', () => expect(main).toContain('Menu'));
    test('handles IPC get-app-info', () => expect(main).toContain('get-app-info'));
    test('handles IPC show-notification', () => expect(main).toContain('show-notification'));
  });

  describe('preload.js', () => {
    let preload;
    beforeAll(() => { preload = fs.readFileSync(path.join(__dirname, 'preload.js'), 'utf8'); });
    test('uses contextBridge', () => expect(preload).toContain('contextBridge'));
    test('exposes electronAPI', () => expect(preload).toContain('electronAPI'));
    test('exposes getAppInfo', () => expect(preload).toContain('getAppInfo'));
    test('exposes showNotification', () => expect(preload).toContain('showNotification'));
    test('exposes platform', () => expect(preload).toContain('platform'));
    test('exposes version info', () => expect(preload).toContain('versions'));
  });

  describe('Window configuration', () => {
    test('default width is 1280', () => {
      const main = fs.readFileSync(path.join(__dirname, 'main.js'), 'utf8');
      expect(main).toContain('width: 1280');
    });
    test('default height is 800', () => {
      const main = fs.readFileSync(path.join(__dirname, 'main.js'), 'utf8');
      expect(main).toContain('height: 800');
    });
    test('minimum width is 800', () => {
      const main = fs.readFileSync(path.join(__dirname, 'main.js'), 'utf8');
      expect(main).toContain('minWidth: 800');
    });
    test('minimum height is 600', () => {
      const main = fs.readFileSync(path.join(__dirname, 'main.js'), 'utf8');
      expect(main).toContain('minHeight: 600');
    });
  });

  describe('File integrity', () => {
    ['package.json', 'main.js', 'preload.js', 'README.md'].forEach(file => {
      test(`${file} exists and non-empty`, () => {
        const p = path.join(__dirname, file);
        expect(fs.existsSync(p)).toBe(true);
        expect(fs.statSync(p).size).toBeGreaterThan(10);
      });
    });
  });
});
