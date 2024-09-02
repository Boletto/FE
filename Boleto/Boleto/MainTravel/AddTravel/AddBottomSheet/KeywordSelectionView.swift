//
//  KeywordSelectionView.swift
//  Boleto
//
//  Created by Sunho on 8/31/24.
//

import SwiftUI

struct KeywordSelectionView: View {
    let keywords = ["봉사", "시골여행", "럭셔리", "순례","워크숍", "나홀로", "졸업여행","휴양", "뚜벅이", "모험","덕직","유적지","쇼핑","가족","느린여행","호캉스","운동","커플","액티비티","관광","식도락"]
    @State private var selectedKeywords: [String] = []
    @State private var showWarning: Bool = false
    @State private var warningTextOpacity: Double = 1.0
    private let gridItems = [GridItem(.adaptive(minimum: 80))]
    
    private let spacing: CGFloat = 10
    var sendKeywords: ([String]) -> (Void)
    var body: some View {
        ZStack {
            Color.modal
            VStack(alignment: .leading) {
                Text("키워드 선택")
                    .padding(.leading,32)
                Text("키워드는 최대 3개까지 결정할 수 있어요")
                    .foregroundStyle(showWarning ? .red : .white)
                    .padding(.leading,32)
                VStack(alignment: .leading , spacing: 12) {
                    ForEach(keywords.chunked(into: 5),id: \.self) {keyword in
                        HStack(spacing: 8){
                            ForEach(keyword,id: \.self) { word in
                                KeyWordCell(keyword: word, onSelect: selectedKeywords.contains(word))
                                    .onTapGesture {
                                       handleKeywordSelection(word)
                                    }
                            }
                        }
                    }
                }.padding(.horizontal,24)
                Button {
                    sendKeywords(selectedKeywords)
                } label: {
                    Text("완료")
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.main)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }.padding(.horizontal, 16)
            }
        }
    }
    private func handleKeywordSelection(_ word: String) {
          if selectedKeywords.contains(word) {
              selectedKeywords.removeAll(where: { $0 == word })
          } else {
              if selectedKeywords.count < 3 {
                  selectedKeywords.append(word)
                  showWarning = false
              } else {
                  showWarning = true
                  // Flash the warning text
                  withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                      warningTextOpacity = 0.5
                  }
              }
          }
      }
    struct KeyWordCell: View{
        let keyword: String
        let onSelect: Bool
        var body: some View {
            Text(keyword)
                .font(.system(size: 15))
                .lineLimit(1)
                .foregroundStyle(.black)
                .padding(.horizontal,13)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 60)
                        .foregroundStyle(onSelect ? Color.main : Color.white)
                )
        }
    }
}
extension Array {
    // 배열을 특정 크기만큼 나누는 헬퍼 함수
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
#Preview {
    KeywordSelectionView() {_ in 
        
    }
}
