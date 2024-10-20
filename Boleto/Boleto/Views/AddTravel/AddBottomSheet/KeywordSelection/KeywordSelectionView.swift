//
//  KeywordSelectionView.swift
//  Boleto
//
//  Created by Sunho on 8/31/24.
//

import SwiftUI
import ComposableArchitecture

struct KeywordSelectionView: View {
    @State private var warningTextOpacity: Double = 1.0
    private let gridItems = [GridItem(.adaptive(minimum: 80))]
    @Bindable var store: StoreOf<KeywordSelectionFeature>
    
    private let spacing: CGFloat = 10

    var body: some View {
            VStack {
                Text("키워드 선택")
                    .foregroundStyle(.white)
                    .customTextStyle(.subheadline)
//                    .padding(.leading,32)
                    .padding(.top, 30)
                    .padding(.bottom, 6)
                    
                Text("키워드는 최대 3개까지 결정할 수 있어요")
                    .foregroundStyle(store.showWarning ? .red2 : .white)
                    .customTextStyle(.small)
                    .padding(.bottom, 10)
                VStack(alignment: .leading , spacing: 12) {
//                    ForEach(Keywords.allCases.map{ $0.koreanString}.chunked(into: 5),id: \.self) {keyword in

                    ForEach(Keywords.allCases.chunked(into: 5),id: \.self) {keyword in
                        HStack(spacing: 8){
                            ForEach(keyword,id: \.self) { word in
                                KeyWordCell(keyword: word.koreanString, onSelect: store.selectedKeywords.contains(word))

//                                KeyWordCell(keyword: word.koreanString, onSelect: store.selectedKeywords.contains(word))
                                    .onTapGesture {
                                        store.send(.tapkeyword(word))
                                    }
                            }
                        }
                    }
                }.padding(.horizontal,24)
                Button {
                    store.send(.tapSubmit)
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
    
    struct KeyWordCell: View{
        let keyword: String
        let onSelect: Bool
        var body: some View {
            Text(keyword)
                .font(.system(size: 14))
                .foregroundStyle(onSelect ? .black : .white)
                .lineLimit(1)
                .padding(.horizontal,13)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 60)
                        .fill(onSelect ? Color.main : Color.clear) // 배경 색상
                        .overlay(
                            RoundedRectangle(cornerRadius: 60)
                                .strokeBorder(onSelect ? .clear : .white, lineWidth: 1) // 테두리 색상
                        )
                        
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
