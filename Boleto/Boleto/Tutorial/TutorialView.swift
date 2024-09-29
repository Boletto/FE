//
//  TutorialView.swift
//  Boleto
//
//  Created by Sunho on 9/29/24.
//

import SwiftUI

struct TutorialView: View {
    @State private var currentPage = 0
    let stages: [TutorialStage] = [.first, .second, .third, .last]
    var finishTutorial: () -> Void
    enum TutorialStage {
        case first
        case second
        case third
        case last
        
        var subString: String {
            switch self {
            case .first:
                "국내 여행의 시작은"
            case .second:
                "지역 명소에 도착하면"
            case .third:
                "직접 찍은 사진을 넣어서"
            case .last:
                "준비가 끝나셨군요"
            }
        }
        var titleString: String {
            switch self {
            case .first:
                "볼레또 티켓과 함께 해요"
            case .second:
                "여행 스티커를 받을 수 있어요"
            case .third:
                "네컷 프레임을 만들 수 있어요"
            case .last:
                "볼레또와 함께 여행을 떠나보세요!"
            }
        }
        var image: Image {
            switch self {
            case .first:
                Image("tutorial1")
            case .second:
                Image("tutorial2")
            case .third:
                Image("tutorial3")
            case .last:
                Image("tutorial4")
            }
        }
        var imageTopPadding: CGFloat {
            switch self {
            case .first:
                81
            case .second:
                29
            case .third:
                81
            case .last:
                73
            }
        }
    }
    var body: some View {
            VStack {
                ZStack {
                    HStack(spacing: 8) {
                        ForEach(0..<stages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? Color.white : Color.gray)
                                .frame(width: 8, height: 8)
                        }
                    }
                    HStack {
              
                        Spacer()
                        Button("건너뛰기") {
                            // 건너뛰기 액션
                        }
                        .foregroundColor(.gray5)
                        .padding()
                    }
                }
                TabView(selection: $currentPage) {
                    ForEach(0..<4, id: \.self) {index in
                        makeStageView(stage: stages[index])
                            .tag(index)
                    }
                }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
              
                Spacer()
            }
        .applyBackground(color: .background)
    }
    func makeStageView(stage: TutorialStage) -> some View {
        VStack {
            Text(stage.subString)
                .foregroundStyle(.gray6)
                .font(.system(size: 20, weight: .regular))
                .padding(.bottom,12)
            Text(stage.titleString)
                .foregroundStyle(.gray6)
                .font(.system(size: 24, weight: .semibold))

            if stage == .last {
                       // 마지막 탭에서만 보여줄 이미지와 버튼
                       VStack {
                           stage.image
                               .resizable()
                               .scaledToFit()
                               .padding(.horizontal,21)
                               .padding(.top, stage.imageTopPadding)
                           Spacer()
                           Button(action: {
                               // 버튼 액션
                           }) {
                               Text("시작하기")
                                   .foregroundColor(.black)
                                   .frame(maxWidth: .infinity)
                                   .frame(height: 56)
                                   .background(.main)
                                   .cornerRadius(30)
                                   .padding(.horizontal, 16)
                           }
                       }
            }else {
                stage.image
                    .resizable()
                    .frame(maxHeight: .infinity)
                    .padding(.top, stage.imageTopPadding)
                    .ignoresSafeArea(edges: .bottom)
            }
            
        }
    }
    
}

#Preview {
    TutorialView()
}
