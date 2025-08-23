import { defineConfig } from '@apps-in-toss/web-framework/config';

export default defineConfig({
  // 앱 기본 정보
  name: 'Flutter Web Demo',
  description: 'Flutter Web을 앱인토스에서 실행하는 데모 앱',

  // 빌드 설정
  build: {
    entry: './src/main.tsx',
    outDir: 'dist',
  },

  // 웹 프레임워크 설정
  framework: 'react',

  // 앱인토스 관련 설정
  apps: {
    // 앱 아이콘이나 기타 메타데이터 설정
    icon: './public/vite.svg',
  }
});


