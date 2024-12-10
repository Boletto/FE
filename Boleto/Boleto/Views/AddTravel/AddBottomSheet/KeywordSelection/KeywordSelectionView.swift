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
    @Bindable var store: StoreOf<KeywordSelectionFeature>

    var body: some View {
        VStack {
            Text("키워드 선택")
                .foregroundStyle(.white)
                .customTextStyle(.subheadline)
                .padding(.top, 30)
                .padding(.bottom, 6)

            HStack(spacing: 5) {
                Image(systemName: "info.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16)
                    .foregroundStyle(.red2)
                    .opacity(store.showWarning ? 1 : 0)
                Text("키워드는 최대 3개까지 결정할 수 있어요")
                    .foregroundStyle(store.showWarning ? .red2 : .white)
                    .customTextStyle(.small)
            }
            .padding(.bottom, 4 )

            DynamicContainerView(
                verticalSpacing: 6,
                horizontalSpacing: 4,
                items: Keywords.allCases.map {
                    KeywordType(title: $0.koreanString, priority: store.selectedKeywords.contains($0) ? 1 : 0)
                }
            ) { item in
                KeyWordCell(keyword: item.title, onSelect: store.selectedKeywords.contains(Keywords.fromKoreanString( item.title)!))
                    .onTapGesture {
                        store.send(.tapkeyword(Keywords.fromKoreanString( item.title)!))
                    }
            }
            .padding(.horizontal, 24)

            Spacer()

            Button {
                store.send(.tapSubmit)
            } label: {
                Text("완료")
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.main)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
            }
            .padding(.horizontal, 16)
        }
    }
}
struct KeyWordCell: View {
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
public struct KeywordType: Equatable {
    let title: String
    let priority: Int
    public init(title: String, priority: Int = 0) {
        self.title = title
        self.priority = priority
    }
    public static func == (lhs: KeywordType, rhs: KeywordType) -> Bool {
      lhs.title == rhs.title
    }
}
public struct DynamicContainerView<Content: View>: View {
    @State private var totalHeight: CGFloat = .zero
    let verticalSpacing: CGFloat
    let horizontalSpacing: CGFloat
    let items: [KeywordType]
    let content: (KeywordType) -> Content

    public init(
        verticalSpacing: CGFloat = 4,
        horizontalSpacing: CGFloat = 4,
        items: [KeywordType],
        @ViewBuilder content: @escaping (KeywordType) -> Content
    ) {
        self.verticalSpacing = verticalSpacing
        self.horizontalSpacing = horizontalSpacing
        self.items = items
        self.content = content
    }

    public var body: some View {
        var width: CGFloat = .zero
        var height: CGFloat = .zero

        return GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ForEach(items, id: \.title) { item in
                    self.content(item)
                        .padding(.horizontal, self.horizontalSpacing / 2)
                        .padding(.vertical, self.verticalSpacing / 2)
                        .alignmentGuide(.leading) { dimension in
                            if abs(width - dimension.width) > geometry.size.width {
                                width = 0
                                height -= dimension.height + self.verticalSpacing
                            }
                            let result = width
                            if item == self.items.last {
                                width = 0 // Reset after the last item
                            } else {
                                width -= dimension.width + self.horizontalSpacing
                            }
                            return result
                        }
                        .alignmentGuide(.top) { _ in
                            let result = height
                            if item == self.items.last {
                                height = 0 // Reset after the last item
                            }
                            return result
                        }
                }
            }
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(key: SizePreferenceKey.self, value: proxy.frame(in: .local).size)
                }
            )
            .onPreferenceChange(SizePreferenceKey.self) { size in
                self.totalHeight = size.height
            }
        }
        .frame(height: totalHeight)
    }
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
