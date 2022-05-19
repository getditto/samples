/* eslint-disable @typescript-eslint/no-var-requires */
const readPkgUp = require('read-pkg-up')

console.log(`Electron builder is running in ${process.env.NODE_ENV} mode`)

module.exports = {
  appId: 'live.ditto.databrowserapp',
  npmRebuild: false,
  buildVersion:
    `${process.env.BUILD_VERSION}` || readPkgUp.sync().packageJson.version,
  productName: readPkgUp.sync().packageJson.productName,
  copyright: 'Copyright (C) 2019 DittoLive - All Rights Reserved',
  afterAllArtifactBuild: './scripts/sign-and-notarize.js',
  directories: {
    output: 'out',
    app: 'dist',
  },
  extraMetadata: {
    version: readPkgUp.sync().packageJson.version,
  },
  mac: {
    category: 'public.app-category.developer-tools',
    // NOTE: the `zip` target is required here for the auto updates to work on MAC OS https://github.com/electron-userland/electron-builder/issues/2199
    target: ['dmg', 'pkg', 'zip', 'mas'],
    artifactName: 'electron-react-ts-${arch}-${channel}.${ext}',
    icon: './assets/icon.icns',
    /**Important to set this setting to true for the packages distributed outside the App Store */
    hardenedRuntime: true,
    entitlements: './assets/entitlements.mac.plist',
    entitlementsInherit: './assets/entitlements.mac.plist',
    asarUnpack: '**/ditto.node',
  },
  mas: {
    provisioningProfile: './assets/embedded.prod.provisionprofile',
    entitlements: './assets/entitlements.mas.plist',
    entitlementsInherit: './assets/entitlements.mas.inherit.plist',
    /** Do not change this setting, it should always be false. */
    hardenedRuntime: false,
    gatekeeperAssess: false,
    asarUnpack: '**/ditto.node',
  },
  win: {
    target: ['nsis'],
    artifactName: 'ditto-data-browser-${arch}-${channel}.${ext}',
    icon: './assets/icon.ico',
    asarUnpack: '**/ditto.node',
  },
  linux: {
    target: ['deb'],
    artifactName: 'ditto-data-browser-${arch}-${channel}.${ext}',
    executableName: 'ditto-data-browser',
    synopsis: 'Electron Ditto Example app',
    category: 'Development',
    icon: './assets/icons/png',
  },
  publish: [
    {
      bucket: 'browser.ditto.live',
      region: 'us-east-1',
      provider: 's3',
      publishAutoUpdate: true,
    },
  ],
}
