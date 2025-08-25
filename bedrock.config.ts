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
    host: '192.168.0.145', // 실기기에서 접근할 수 있는 IP 주소
    port: 5174,
    commands: {
      dev: 'vite --host', // --host 옵션 활성화
      build: 'tsc -b && vite build',
    },
  },
  permissions: [],
  webViewProps: {
    type: 'game', // Flutter 앱이므로 전체 화면 사용
  },
});
