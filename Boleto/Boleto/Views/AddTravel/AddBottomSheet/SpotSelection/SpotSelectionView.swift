//
//  SpotSelectionView.swift
//  Boleto
//
//  Created by Sunho on 8/31/24.
//

import SwiftUI
import ComposableArchitecture
struct SpotSelectionView: View {
    @Bindable var store: StoreOf<SpotSelectionFeature>
    var body: some View {
        VStack {
            Text(store.isDepartureStep ? "출발지 선택" : "도착지 선택")
                .customTextStyle(.subheadline)
                .foregroundStyle(.white)
                .padding(.top,24)
            
  
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3),spacing: 16) {
                ForEach(SpotType.allCases) { type in
                    let spot = type.spot
                    Button {
                        store.send(.selectSpot(type))
                    } label: {
                        Text(spot.name)
                            .frame(maxWidth: .infinity)
                            .customTextStyle(.body1)
                            .padding(.vertical, 6)
                            .background(type.id == store.selectedSpot?.id ? Color.main : Color.white)
                            .foregroundColor(type.id == store.selectedSpot?.id ? .white : .black)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
                }
            }.padding(.horizontal, 32)
            Spacer()
            Button(action: {
                store.send(.nextStep)
            }, label: {
                Text(store.isDepartureStep ? "다음" : "완료")
                    .font(.system(size: 16,weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.main)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
            }).disabled(store.selectedSpot == nil)
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    SpotSelectionView(store: Store(initialState: SpotSelectionFeature.State()){
        SpotSelectionFeature()
    })
    
}
