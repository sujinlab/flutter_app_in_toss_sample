import { useEffect, useRef, useState } from "react";

// Flutter 타입 정의
interface FlutterEngineInitializer {
  initializeEngine: (config: {
    hostElement: HTMLElement | null;
    assetBase: string;
  }) => Promise<FlutterAppRunner>;
}

interface FlutterAppRunner {
  runApp: () => Promise<void>;
}

interface FlutterBuild {
  compileTarget?: string;
  renderer?: string;
  mainJsPath?: string;
}

interface FlutterBuildConfig {
  entrypointUrl?: string;
  assetBase?: string;
  engineRevision?: string;
  builds?: FlutterBuild[];
}

declare global {
  interface Window {
    _flutter?: {
      loader?: {
        load: (config: {
          onEntrypointLoaded: (
            engineInitializer: FlutterEngineInitializer
          ) => void;
        }) => void;
      };
      buildConfig?: FlutterBuildConfig;
    };
  }
}

const FlutterCanvas = () => {
  const containerRef = useRef<HTMLDivElement>(null);
  const scriptRef = useRef<HTMLScriptElement | null>(null);
  const loaderTimeoutRef = useRef<number | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    // 중복 로드 방지
    if (scriptRef.current) {
      return;
    }

    // Flutter 스크립트 로드
    const script = document.createElement("script");
    script.src = "/flutter/flutter_bootstrap.js";
    script.async = true;
    scriptRef.current = script;

    // 컨테이너 참조 저장 (cleanup에서 사용)
    const container = containerRef.current;

    script.onload = () => {
      // Flutter 로더가 준비될 때까지 대기
      const checkFlutterLoader = () => {
        if (window._flutter && window._flutter.loader) {
          try {
            // Flutter 설정 수정 - 올바른 경로 설정
            if (window._flutter.buildConfig) {
              window._flutter.buildConfig.entrypointUrl =
                "/flutter/main.dart.js";
              window._flutter.buildConfig.assetBase = "/flutter/";

              // builds 배열의 mainJsPath도 수정
              if (
                window._flutter.buildConfig.builds &&
                window._flutter.buildConfig.builds[0]
              ) {
                window._flutter.buildConfig.builds[0].mainJsPath =
                  "/flutter/main.dart.js";
              }
            }

            // Flutter 앱 로드
            window._flutter.loader.load({
              onEntrypointLoaded: async (
                engineInitializer: FlutterEngineInitializer
              ) => {
                try {
                  // Flutter 엔진 생성
                  const appRunner = await engineInitializer.initializeEngine({
                    hostElement: containerRef.current,
                    assetBase: "/flutter/",
                  });

                  // Flutter 앱 실행
                  await appRunner.runApp();

                  // Flutter 캔버스 스타일 강제 적용
                  setTimeout(() => {
                    const canvas =
                      containerRef.current?.querySelector("canvas");
                    if (canvas) {
                      canvas.style.width = "100%";
                      canvas.style.height = "100%";
                      canvas.style.display = "block";
                      canvas.style.margin = "0";
                      canvas.style.padding = "0";
                      canvas.style.border = "none";
                      canvas.style.outline = "none";
                    }

                    // Flutter 루트 요소 스타일 적용
                    const flutterView = containerRef.current?.querySelector(
                      "flutter-view, flt-glass-pane"
                    );
                    if (flutterView) {
                      (flutterView as HTMLElement).style.width = "100%";
                      (flutterView as HTMLElement).style.height = "100%";
                    }
                  }, 100);
                } catch (err) {
                  console.error("Flutter 앱 실행 실패:", err);
                  setError("Flutter 앱을 실행할 수 없습니다.");
                }
              },
            });
          } catch (err) {
            console.error("Flutter 로더 설정 실패:", err);
            setError("Flutter 로더 설정에 실패했습니다.");
          }
        } else {
          // 아직 로더가 준비되지 않았으면 다시 시도 (최대 30초)
          loaderTimeoutRef.current = setTimeout(checkFlutterLoader, 100);
        }
      };

      checkFlutterLoader();
    };

    script.onerror = () => {
      console.error("Flutter 스크립트 로드 실패");
      setError("Flutter 스크립트를 로드할 수 없습니다.");
    };

    document.head.appendChild(script);

    return () => {
      // 정리 작업
      if (loaderTimeoutRef.current) {
        clearTimeout(loaderTimeoutRef.current);
        loaderTimeoutRef.current = null;
      }

      if (scriptRef.current && scriptRef.current.parentNode) {
        scriptRef.current.parentNode.removeChild(scriptRef.current);
        scriptRef.current = null;
      }

      // Flutter 컨테이너 정리
      if (container) {
        container.innerHTML = "";
      }
    };
  }, []);

  // 에러 상태 렌더링
  if (error) {
    return (
      <div
        style={{
          width: "100vw",
          height: "100vh",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          flexDirection: "column",
          background: "#ffffff",
          color: "#333",
          fontFamily: "Arial, sans-serif",
        }}
      >
        <h2>Flutter 앱 로드 오류</h2>
        <p>{error}</p>
        <button
          onClick={() => window.location.reload()}
          style={{
            padding: "10px 20px",
            backgroundColor: "#007bff",
            color: "white",
            border: "none",
            borderRadius: "5px",
            cursor: "pointer",
            marginTop: "10px",
          }}
        >
          다시 시도
        </button>
      </div>
    );
  }

  return (
    <div
      style={{
        width: "100%",
        height: "100%",
        position: "relative",
        overflow: "hidden",
        display: "flex",
        flexDirection: "column",
      }}
    >
      {/* Flutter 앱 컨테이너 */}
      <div
        ref={containerRef}
        style={{
          width: "100%",
          height: "100%",
          flex: 1,
          background: "#ffffff",
          overflow: "hidden",
          position: "relative",
        }}
      />
    </div>
  );
};

export default FlutterCanvas;
