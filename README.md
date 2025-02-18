# Boletto-iOS
SwiftUI + TCA를 활용한 iOS 여행 기록 및 공유 애플리케이션입니다.

---

## ✈️ Boletto 소개
Boleto는 여행의 모든 순간을 기록하고, 나만의 방식으로 꾸밀 수 있는 여행 기록 및 공유 앱입니다.
![슬로건 그래픽](https://github.com/user-attachments/assets/e30ec7da-0bdd-4cac-a627-9a4327a8143d)
<p align="center">
  <img src="https://github.com/user-attachments/assets/4052b9a9-3c57-4d70-bf05-fe22c412c313" width="280" />
  <img src="https://github.com/user-attachments/assets/d775950d-e461-4291-8118-55f864259b74" width="280" />
  <img src="https://github.com/user-attachments/assets/95f2e566-9cb6-4119-b56e-db7f2742a5cc" width="280" />
</p>

 <p align="center">  
  <a href="https://apps.apple.com/kr/app/볼레또/id6737753864">  
    <img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" alt="Download on the App Store" width="180">  
  </a>  
</p>  

### 🆕 최신 업데이트
- **1.1 버전:** 크리스마스 티켓, 인스타그램 스토리 공유 기능 추가
- **1.2 버전:** 설날 티켓 및 사진 편집 기능 추가

---

## ⚒️ 주요 기능
### 🗺️ 위치 기반 이벤트
- CLMonitor 및 CLServiceSession을 활용하여 특정 명소 도착 시, 명소를 그린 스티커와 사용자 맞춤 프레임 제공
- 백그라운드에서도 이벤트 트리거 및 로컬 알림 지원

### 🎨 티켓 커스터마이즈
- 획득한 스티커와 프레임을 이용해 네컷 또는 폴라로이드 티켓 꾸미기
- 제스처를 통해 스티커 확대, 축소, 회전 등 자유로운 편집

### 👥 친구와 함께하는 여행 기록
- 실시간 티켓 공동 편집 및 충돌 방지를 위한 Lock/Unlock 관리
- 유니버설 링크를 통해 친구 초대 및 여행 기록 공유
- 인스타그램 스토리 공유 기능 지원

---

## 💻 기술 스택
### **Frameworks & Libraries**
- **SwiftUI:** 전체 UI 구성 및 애니메이션 구현
- **UIKit:** ShareLink 관련 기능 UIViewRepresentable로 보완
- **CoreLocation:** 위치 이벤트 모니터링 및 스티커 제공
- **SwiftData:** 스티커 및 프레임 로컬 캐싱
- **Alamofire:** RequestInterceptor를 통한 인증 토큰 자동 갱신 및 API 통신

## **Architecture**
- **Composable Architecture (TCA):**
- 이 프로젝트는 **Composable Architecture (TCA)** 를 중심으로 설계되었으며, 주요 목표는 단방향 데이터 흐름, 명확한 상태 관리, 모듈화 통해 코드의 유지보수성, 재사용성을 극대화하는 것입니다.
<img width="640" alt="image" src="https://github.com/user-attachments/assets/18f1fdba-bb6d-44fe-a741-43a53b194f1a" />

## 📌 모듈화된 Reducer 설계
각 화면이나 주요 기능은 **Reducer**로 구현되었으며, 비즈니스 로직과 상태 관리를 담당합니다. 이를 통해 기능별로 독립적인 모듈화를 이루었습니다.

### 🛠 Reducer 구성 예시:
- **`AppFeature`**: 앱 전체의 상태 및 화면 전환 관리  
- **`AddTicketFeature`**: 여행 티켓 추가 및 편집 로직 관리  
- **`MemoryFeature`**: 여행 추억 관리 (스티커 및 사진 편집 포함)  
- **`LoginFeature`**: 카카오 및 애플 로그인 플로우 처리  
- **`MyPageFeature`**: 사용자 정보 및 설정 화면 관리  

---

## 🔄 단방향 데이터 흐름  
모든 상태 변화는 `Action → Reducer → State`의 흐름을 따릅니다. 이를 통해 상태 변경을 명확하게 추적할 수 있으며, 디버깅이 용이합니다.

### ✅ 예시:
1. 사용자가 티켓을 추가 또는 수정하면 **Action**을 발생시킴  
2. **Reducer**에서 해당 액션을 처리하여 **State**를 업데이트  
3. 업데이트된 **State**를 바탕으로 UI가 자동 갱신  

---

## 🏗 Dependency Injection  
네트워크 요청, 데이터베이스 연동, 로컬 저장소 등 **외부 의존성**을 `Dependency`를 통해 주입했습니다. 이를 통해 **테스트 용이성**을 높이고, 외부 의존성을 쉽게 교체할 수 있도록 설계했습니다.

### 💡 의존성 주입 예시:
```swift
@Dependency(\.userClient) var userClient를 통해 사용자 관련 API 호출을 관리.
의존성 주입 사용 사례:
userClient: 사용자 정보 및 프로필 변경.
travelClient: 여행 티켓 추가, 수정, 삭제.
locationClient: 위치 기반 모니터링.
databaseClient: 스티커 및 프레임 데이터베이스 관리.
```
## 🔄 재사용 가능한 컴포넌트 설계  

TCA의 **모듈화된 구조**를 활용하여 **재사용 가능한 기능**을 구현했습니다.  

### 📌 예시:  
- **스티커 관리, 사진 편집, 알람 기능** 등은 여러 화면에서 활용 가능  
- **공통 기능으로 분리된 Feature**:  
  - `StickerManagementFeature`  
  - `PhotoGridFeature`  

이러한 구조를 통해 코드의 **유지보수성과 확장성**을 극대화하였습니다.  

---

## 🧪 테스트 가능성 강화  

TCA는 **테스트 작성에 용이한 구조**를 제공합니다.  
각 **Reducer**와 **의존성을 분리**하여 **단위 테스트**를 쉽게 작성할 수 있도록 설계되었습니다.  

### ✅ 테스트 가능 구조:  
- 각 **Reducer**의 비즈니스 로직을 독립적으로 테스트 가능  
- **Mock Dependency** 주입을 통해 다양한 시나리오 검증 가능  

이러한 설계를 통해 **안정적인 애플리케이션 유지보수**가 가능합니다.  



##### Location Monitoring Flow
<img width="640" alt="image" src="https://github.com/user-attachments/assets/a76bca86-7a28-460c-b7a3-4b33e0b86b4d" />

1. 사일런트 푸쉬나 AllticketOverViewFeature에서 티켓들을 get요청 후 해당날짜의 티켓이 있으면 Appfeature에서 .startMonitoring(Spot)발생.
2. LocationClient 내부의 LocationActor에서 CLMonitor생성 후 AsyncStream<MonitorEvent>반환

3. 특정 지역 진입 등 이벤트 발생시 CLMonitor.events -> LocationAcotr -> LocationClient -> LocationMonitoringFeature로 전달

4. LocationMonitoringFeature에서 해당 이벤트에 따른 알림, 서버 푸쉬, SwiftData에 저장 등 추가 액션.


---

## 📋 요구사항
- **iOS:** 17.0+
- **Xcode:** 15.0+
- **Swift:** 5.9+

---
