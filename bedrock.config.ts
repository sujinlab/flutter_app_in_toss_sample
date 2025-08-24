import { defineConfig } from '@apps-in-toss/web-framework/config';

export default defineConfig({
  appName: 'heylocal',
  brand: {
    displayName: 'demo', // 화면에 노출될 앱의 한글 이름
    primaryColor: '#2196F3', // Flutter 블루 색상
    icon: './public/vite.svg', // 앱 아이콘
    bridgeColorMode: 'basic',
  },
  web: {
    host: 'localhost',
    port: 5174, // 현재 사용 중인 포트
    commands: {
      dev: 'vite',
      build: 'tsc -b && vite build',
    },
  },
  permissions: [],
  webViewProps: {
    type: 'game', // Flutter 앱이므로 전체 화면 사용
  },
});
