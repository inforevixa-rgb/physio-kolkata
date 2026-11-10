import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.physiokolkata.app',
  appName: 'Physio Kolkata',
  webDir: 'web',
  bundledWebRuntime: false,
  android: {
    allowMixedContent: false
  }
};

export default config;
