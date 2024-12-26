# Boletto-iOS
SwiftUI + TCA를 활용해 개발한 iOS 여행 기록 및 공유 애플리케이션입니다.
## ✈️ Boletto
<aside>
Boleto는 여행의 모든 순간을 기록하고,사용자만의 독창적인 방식으로 꾸밀 수 있도록 설계된 여행 기록 및 공유 앱입니다.
</aside>

![슬로건 그래픽](https://github.com/user-attachments/assets/e30ec7da-0bdd-4cac-a627-9a4327a8143d)

## ⚒️ Main Feature

### 1️⃣ 위치기반 모니터링
- **CLMonitor**와 **CLServiceSession**을 활용하여 백그라운드에서도 특정 명소에 도달하면 스티커와 프레임을 제공받는 이벤트를 트리거합니다.
- 명소 도착 시, 해당 위치만의 특별한 스티커와 프레임을 제공받아 여행의 즐거움을 더합니다.
  
### 2️⃣ 티켓 커스텀 꾸미기
- 여행 중 획득한 스티커와 프레임을 이용해 **네컷**, **폴라로이드 티켓**을 꾸밀 수 있습니다.
- **제스처 기능**을 활용하여 스티커나 말풍선을 확대/축소하거나 회전하여 원하는 위치에 배치합니다.

### 3️⃣ 친구와 함께하는 여행기록
- 친구와 **실시간으로 티켓을 공동 편집**하며, 여행의 추억을 함께 기록합니다.
- **Lock/Unlock 관리**를 통해 충돌 없이 안정적인 공동 편집 환경을 제공합니다.
- **유니버설 링크**를 통해 친구를 초대하고 함께 여행을 기록할 수 있습니다.
- 꾸민 티켓들을 Instagram 스토리로 공유 할 수 있습니다.

  
## 🙏🏻 요구사항 
- iOS 17+
- XCode 15.0+
- Swift 5.9+

## 💻Tech Stack
### **Frameworks & Libraries**
- SwiftUI: 전체적인 코드는 SwiftUI 기반으로 진행.
- UiKit: ShareLink로는 열리기 직전에 이벤트 처리를 할 수 없어 필요한 기능은 UIViewRepresentable으로 구현.
- CoreLocation: CLMointor를 통해 지정해놓은 위치 이벤트 확인.
- TCA: 여행티켓 관리라는 주요 기능을 중심으로 명확한 상태 관리, 단방향 흐름, 모듈화를 통해 테스트코드까지 작성.
- SwiftData: 프레임, 스티커 로컬 캐싱.
- Alamofire: RequestInterceptor를 활용한 인증 토큰 자동 갱신 및 안전한 저장을 포함한 네트워크 계층 설계 및 API 통신.
### **Architecture**
- **Composable Architecture (TCA)**:  
  - 티켓 편집, 위치 기반 이벤트 등 주요 기능을 컴포넌트로 분리.  
  - 단방향 데이터 흐름과 명확한 상태 관리를 통해 기능 구현.  
  - 모듈화를 통한 재사용성과 테스트 용이성 강화.  


