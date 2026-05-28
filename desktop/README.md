# CalMaster — Desktop App

> Scientific calculator & unit converter

## Platforms

| Platform | Format | Architecture |
|---|---|---|
| macOS | `.dmg` | x64, arm64 (Apple Silicon) |
| Windows | `.exe` (NSIS installer) | x64 |
| Linux | `.AppImage`, `.deb` | x64 |

## Development

```bash
cd desktop
npm install
npm start          # Launch in development mode
npm run build      # Build for all platforms
npm run build:mac  # macOS only
npm run build:win  # Windows only
npm test           # Run desktop tests
```

## Architecture

- **main.js** — Electron main process (window management, IPC, native menus)
- **preload.js** — Context bridge (secure IPC between renderer and main)
- **Renderer** — Loads the web app from `americangroupllc.com`

## Features

- Native macOS/Windows/Linux menus
- System notifications
- Keyboard shortcuts (Cmd/Ctrl+N, zoom, reload)
- Secure context isolation
- Auto-updater ready
- Minimum window size enforcement (800×600)
