//
//  AddTravelView.swift
//  Boleto
//
//  Created by Sunho on 8/31/24.
//

import SwiftUI
import ComposableArchitecture

struct AddTravelView: View {
    @Bindable var store: StoreOf< AddTravelFeature>
    var body: some View {

            VStack {
                Text("아직 진행 중인 여행이 없어요!")
                    .foregroundStyle(.gray3)
                    .customTextStyle(.body1)
                    .padding(.top, 137)
                    .padding(.bottom,42)
                Image("addLogo")
                    Spacer()
                HStack(spacing: 0) {
                    ZStack(alignment: .trailing) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundStyle(.main)
                            VStack(alignment:.leading, spacing: 6) {
                                Text("여행 추가하고 티켓 생성하기")
                                    .customTextStyle(.normal)
                                    .foregroundStyle(.gray1)
                                Text("추억을 기록해보세요!")
                                    .customTextStyle(.small)
                            }
                        }
                        .frame(width: 253, height: 80)
                        DottedLine()
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [3]))
                            .frame(width: 1, height: 62)
                    }
               
                    ZStack{
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.main)
                        ZStack {
                            Circle().frame(width: 26)
                                .foregroundStyle(.gray1)
                            Image(systemName: "chevron.right")
                            .foregroundStyle(.white)
                        }
                    }.frame(width: 76, height: 80)
                }
                .padding(.bottom, 36)
                .onTapGesture {
                    store.send(.gotoAddTicket)
                }
            }

    }
}

#Preview {
    AddTravelView(store:Store(initialState: AddTravelFeature.State(), reducer: {
        AddTravelFeature()
    }) )
}
