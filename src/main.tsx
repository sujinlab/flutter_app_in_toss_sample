import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import "./index.css";
import App from "./App.tsx";
import { 
  getDeviceId, 
  share, 
  appLogin, 
  startUpdateLocation, 
  Accuracy,
  fetchAlbumPhotos,
  generateHapticFeedback,
  IAP,
  checkoutPayment
} from "@apps-in-toss/web-framework";

// Flutter 웹앱에서 호출할 수 있도록 전역 함수로 등록
declare global {
  interface Window {
    flutterGetDeviceId: () => string;
    flutterShare: (message: string) => Promise<void>;
    flutterAppLogin: () => Promise<{ authorizationCode: string; referrer: string }>;
    flutterStartUpdateLocation: (
      accuracy: string,
      timeInterval: number,
      distanceInterval: number,
      onLocationUpdate: (location: any) => void,
      onError: (error: any) => void
    ) => () => void;
    flutterFetchAlbumPhotos: (
      base64: boolean,
      maxWidth: number,
      onSuccess: (photos: any[]) => void,
      onError: (error: any) => void
    ) => void;
    flutterGenerateHapticFeedback: (
      type: string,
      onSuccess: () => void,
      onError: (error: any) => void
    ) => void;
    flutterGetProductItemList: (
      onSuccess: (products: any[]) => void,
      onError: (error: any) => void
    ) => void;
    flutterCreateOneTimePurchaseOrder: (
      productId: string,
      onSuccess: (result: any) => void,
      onError: (error: any) => void
    ) => void;
    flutterCheckoutPayment: (
      payToken: string,
      onSuccess: (result: any) => void,
      onError: (error: any) => void
    ) => void;
    flutterAccuracy: typeof Accuracy;
  }
}

// Flutter에서 호출할 수 있는 함수들 정의
window.flutterGetDeviceId = () => {
  return getDeviceId();
};

window.flutterShare = async (message: string) => {
  try {
    await share({ message });
    console.log("공유 완료");
  } catch (error) {
    console.error("공유 실패:", error);
    throw error;
  }
};

window.flutterAppLogin = async () => {
  try {
    const result = await appLogin();
    console.log("로그인 성공:", result);
    return result;
  } catch (error) {
    console.error("로그인 실패:", error);
    throw error;
  }
};

window.flutterStartUpdateLocation = (
  accuracy: string,
  timeInterval: number,
  distanceInterval: number,
  onLocationUpdate: (location: any) => void,
  onError: (error: any) => void
) => {
  // accuracy 문자열을 Accuracy enum으로 변환
  let accuracyEnum;
  switch (accuracy) {
    case 'High':
      accuracyEnum = Accuracy.High;
      break;
    case 'Balanced':
      accuracyEnum = Accuracy.Balanced;
      break;
    case 'Low':
      accuracyEnum = Accuracy.Low;
      break;
    default:
      accuracyEnum = Accuracy.Balanced;
  }

  return startUpdateLocation({
    options: {
      accuracy: accuracyEnum,
      timeInterval,
      distanceInterval,
    },
    onEvent: onLocationUpdate,
    onError,
  });
};

window.flutterFetchAlbumPhotos = async (
  base64: boolean,
  maxWidth: number,
  onSuccess: (photos: any[]) => void,
  onError: (error: any) => void
) => {
  try {
    const response = await fetchAlbumPhotos({
      base64,
      maxWidth,
    });
    console.log("앨범 사진 가져오기 성공:", response);
    onSuccess(response);
  } catch (error) {
    console.error("앨범 사진 가져오기 실패:", error);
    onError(error);
  }
};

window.flutterGenerateHapticFeedback = async (
  type: string,
  onSuccess: () => void,
  onError: (error: any) => void
) => {
  try {
    await generateHapticFeedback({ type: type as any });
    console.log("햅틱 피드백 성공:", type);
    onSuccess();
  } catch (error) {
    console.error("햅틱 피드백 실패:", error);
    onError(error);
  }
};

window.flutterGetProductItemList = async (
  onSuccess: (products: any[]) => void,
  onError: (error: any) => void
) => {
  try {
    const response = await IAP.getProductItemList();
    console.log("상품 목록 가져오기 성공:", response);
    const products = response?.products || [];
    onSuccess(products);
  } catch (error) {
    console.error("상품 목록 가져오기 실패:", error);
    onError(error);
  }
};

window.flutterCreateOneTimePurchaseOrder = async (
  productId: string,
  onSuccess: (result: any) => void,
  onError: (error: any) => void
) => {
  try {
    const result = await IAP.createOneTimePurchaseOrder({ productId });
    console.log("인앱 결제 성공:", result);
    onSuccess(result);
  } catch (error) {
    console.error("인앱 결제 실패:", error);
    onError(error);
  }
};

window.flutterCheckoutPayment = async (
  payToken: string,
  onSuccess: (result: any) => void,
  onError: (error: any) => void
) => {
  try {
    const result = await checkoutPayment({ payToken });
    console.log("토스페이 결제 인증 결과:", result);
    onSuccess(result);
  } catch (error) {
    console.error("토스페이 결제 인증 실패:", error);
    onError(error);
  }
};

// Accuracy enum을 Flutter에서 참조할 수 있도록 노출
window.flutterAccuracy = Accuracy;

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <App />
  </StrictMode>
);
