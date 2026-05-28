// CalMaster — Browser Extension Tests
// Tests cover: manifest validity, background SW, content script, popup, storage

const fs = require('fs');
const path = require('path');

describe('CalMaster Browser Extension', () => {

  // ── Manifest ──────────────────────────────────────────────────────
  describe('manifest.json', () => {
    let manifest;
    beforeAll(() => {
      manifest = JSON.parse(fs.readFileSync(path.join(__dirname, 'manifest.json'), 'utf8'));
    });

    test('manifest version is 3', () => {
      expect(manifest.manifest_version).toBe(3);
    });
    test('name matches app', () => {
      expect(manifest.name).toBe('CalMaster');
    });
    test('version follows semver', () => {
      expect(manifest.version).toMatch(/^\d+\.\d+\.\d+$/);
    });
    test('has background service worker', () => {
      expect(manifest.background?.service_worker).toBe('background.js');
    });
    test('has content scripts', () => {
      expect(manifest.content_scripts?.length).toBeGreaterThan(0);
    });
    test('has action popup', () => {
      expect(manifest.action?.default_popup).toBe('popup.html');
    });
    test('has required permissions', () => {
      expect(manifest.permissions).toContain('storage');
      expect(manifest.permissions).toContain('activeTab');
    });
    test('has host permissions for AGL API', () => {
      expect(manifest.host_permissions).toContain('https://api.americangroupllc.com/*');
    });
    test('has icons defined', () => {
      expect(manifest.icons?.['48']).toBeDefined();
      expect(manifest.icons?.['128']).toBeDefined();
    });
  });

  // ── Background Service Worker ─────────────────────────────────────
  describe('background.js', () => {
    let bgContent;
    beforeAll(() => {
      bgContent = fs.readFileSync(path.join(__dirname, 'background.js'), 'utf8');
    });

    test('registers onInstalled listener', () => {
      expect(bgContent).toContain('onInstalled.addListener');
    });
    test('registers onMessage listener', () => {
      expect(bgContent).toContain('onMessage.addListener');
    });
    test('handles FETCH_DATA message type', () => {
      expect(bgContent).toContain("'FETCH_DATA'");
    });
    test('handles NOTIFY message type', () => {
      expect(bgContent).toContain("'NOTIFY'");
    });
    test('sets up periodic alarm sync', () => {
      expect(bgContent).toContain('chrome.alarms.create');
    });
    test('references correct API base', () => {
      expect(bgContent).toContain('api.americangroupllc.com');
    });
  });

  // ── Content Script ────────────────────────────────────────────────
  describe('content.js', () => {
    let csContent;
    beforeAll(() => {
      csContent = fs.readFileSync(path.join(__dirname, 'content.js'), 'utf8');
    });

    test('uses IIFE pattern for isolation', () => {
      expect(csContent).toContain("'use strict'");
    });
    test('injects FAB element', () => {
      expect(csContent).toContain('createElement');
    });
    test('FAB has correct app id', () => {
      expect(csContent).toContain('calmaster-fab');
    });
    test('FAB uses brand color', () => {
      expect(csContent).toContain('#37474F');
    });
    test('handles DOMContentLoaded', () => {
      expect(csContent).toContain('DOMContentLoaded');
    });
    test('sends message to runtime on click', () => {
      expect(csContent).toContain('chrome.runtime.sendMessage');
    });
  });

  // ── Popup ─────────────────────────────────────────────────────────
  describe('popup.html', () => {
    let htmlContent;
    beforeAll(() => {
      htmlContent = fs.readFileSync(path.join(__dirname, 'popup.html'), 'utf8');
    });

    test('has correct DOCTYPE', () => {
      expect(htmlContent).toContain('<!DOCTYPE html>');
    });
    test('references popup.js script', () => {
      expect(htmlContent).toContain('popup.js');
    });
    test('has open app button', () => {
      expect(htmlContent).toContain('openApp');
    });
    test('has notification toggle button', () => {
      expect(htmlContent).toContain('toggleNotif');
    });
    test('uses brand color in styles', () => {
      expect(htmlContent).toContain('#37474F');
    });
    test('has app name in title', () => {
      expect(htmlContent).toContain('CalMaster');
    });
  });

  // ── Popup JS ──────────────────────────────────────────────────────
  describe('popup.js', () => {
    let jsContent;
    beforeAll(() => {
      jsContent = fs.readFileSync(path.join(__dirname, 'popup.js'), 'utf8');
    });

    test('listens for DOMContentLoaded', () => {
      expect(jsContent).toContain('DOMContentLoaded');
    });
    test('reads storage for notification state', () => {
      expect(jsContent).toContain('chrome.storage.local.get');
    });
    test('opens app tab on button click', () => {
      expect(jsContent).toContain('chrome.tabs.create');
    });
    test('toggles notification state in storage', () => {
      expect(jsContent).toContain('chrome.storage.local.set');
    });
  });

  // ── File integrity ────────────────────────────────────────────────
  describe('file integrity', () => {
    const requiredFiles = ['manifest.json','background.js','content.js','popup.html','popup.js'];
    requiredFiles.forEach(file => {
      test(`${file} exists and is non-empty`, () => {
        const p = path.join(__dirname, file);
        expect(fs.existsSync(p)).toBe(true);
        expect(fs.statSync(p).size).toBeGreaterThan(10);
      });
    });
  });
});
