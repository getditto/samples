# Tasks Electron React TS

This project was bootstrapped with [electron-quick-start-typescript](https://github.com/electron/electron-quick-start-typescript).

1. First run `npm install`
2. Add your offline license token to `src/App.tsx`
3. Run `npm start`

## Node.js Integration

This sample enables Electron's Node.js integration and disables context isolation to allow using Node.js APIs from the renderer process. If your renderer process loads remote content, you should isolate Ditto to the main process or to a separate renderer process to avoid introducing security vulnerabilities. Read more about this in Electron's [security docs](https://www.electronjs.org/docs/latest/tutorial/security#2-do-not-enable-nodejs-integration-for-remote-content).

## Bluetooth Low Energy on macOS

If the Bluetooth Low Energy P2P transport is enabled, the application might crash in development when running on macOS due to missing permissions. In order to fix this, add your terminal app (or the app that you use to run this sample) to the list of apps allowed to use Bluetooth under **System Preferences > Security & Privacy > Bluetooth**.

## Bluetooth Low Energy on Linux

Please refer to [the docs](https://docs.ditto.live/installation/linux) for instructions on how to enable Bluetooth Low Energy on Linux.
