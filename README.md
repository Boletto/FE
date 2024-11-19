# Boletto-iOS
SwiftUI + TCA로 개발을 진행했습니다.
## ✈️ Boletto
<aside>
국내여행 경험을 새롭게!
나만의 여행 컬렉션으로 추억을 함께하세요
여행을 티켓으로 표현하고, 인생네컷, 스티커 등 다양하게 본인만의 티켓을 완성하세요

</aside>

## ⚒️ Main Feature

1️⃣ 위치기반 모니터링
- 서울, 제주, 부산 등 다양한 지역의 관광명소를 CLMointor로 관리하여 사용자의 위치를 통해 스티커, 프레임 등을 획득할 수 있습니다.
  
2️⃣ 티켓 커스텀 꾸미기
- 해당 위치로 가서 받은 스티커, 프레임등을 통해 인생 네컷, 폴라로이드와 함께 꾸밀 수 있습니다.
- 함께하는 친구와 동시에 꾸미는 작업을 할 수 있습니다.
  
## 🙏🏻 요구사항 
- iOS 17+
- XCode 15.0+
- Swift 5.9+

## Tech Stack
- SwiftUI: 전체적인 코드는 SwiftUI 기반.
- UiKit: ShareLink로는 열리기 직전에 이벤트 처리를 할 수 없어 필요한 기능은 UIViewRepresentable으로 구현.
- CoreLocation: CLMointor를 통해 지정해놓은 위치 이벤트 확인.
- TCA: 여행티켓 관리라는 주요 기능을 중심으로 명확한 상태 관리, 단방향 흐름, 모듈화를 통해 테스트코드까지 작성할 수 있었습니다.

## Folder Structrue
📦 **Boleto**  
┣ 📂 **Boleto**  
┃ ┣ 📂 **App**  
┃ ┣ 📂 **Assets.xcassets**  
┃ ┣ 📂 **Client**  
┃ ┣ 📂 **Extensions**  
┃ ┣ 📂 **Fonts**  
┃ ┣ 📂 **LocalDB**  
┃ ┣ 📂 **Models**  
┃ ┗ 📂 **Features**  
┃ ┣ 📂 **Network**  
┃ ┃ ┣ 📂 **Bases**  
┃ ┃ ┣ 📂 **DTO**  
┃ ┃ ┗ 📂 **Router**  
┃ ┗ 📂 **Views**  
┃ ┃ ┣ 📂 **AddTravel**  
┃ ┃ ┣ 📂 **Alarms**  
┃ ┃ ┣ 📂 **Components**  
┃ ┃ ┣ 📂 **DetailTravel**  
┃ ┃ ┣ 📂 **Login**  
┃ ┃ ┣ 📂 **MyPage**  
┃ ┃ ┗ 📂 **Tutorial**  
┣ 📂 **BoletoTests**  
┗ 📂 **BoletoUITests**
<p align="center">  
<!-- <img src="https://github.com/Team-Going/Going-iOS/assets/102219161/6fabdfe3-4276-43cc-8120-a6c5e60b5758" align="center" width="15%">  
<img src="https://github.com/Team-Going/Going-iOS/assets/102219161/2f74f4c6-31b7-4373-8e69-e24ba902a8a2" align="center" width="15%">  
<img src="https://github.com/Team-Going/Going-iOS/assets/102219161/4e2484f4-5771-459a-b99e-7ed407a32801" align="center" width="15%"> 
<img src="https://github.com/Team-Going/Going-iOS/assets/102219161/bf8611ed-3d69-4b88-8d23-1728f3b1b3f4" align="center" width="15%"> 
<img src="https://github.com/Team-Going/Going-iOS/assets/102219161/fc49f15f-c50c-4898-8dc0-f38109eb5720" align="center" width="15%"> -->
</p>
