//
//  AddTicketView.swift
//  Boleto
//
//  Created by Sunho on 8/31/24.
//

import SwiftUI
import ComposableArchitecture

struct AddTicketView: View {
    @Bindable var store: StoreOf<AddTicketFeature>
    var body: some View {
        VStack(spacing: 12) {
            Text("여행을 떠날 준비 되셨나요?")
                .foregroundStyle(.white)
                .customTextStyle(.title)
                .padding(.top, 40)
                .padding(.bottom, 4)
            Text("여행 정보를 입력하고, 함께하는 친구를 초대해\n우리들만의 추억을 담은 티켓을 만들어보세요")
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray5)
                .customTextStyle(.body1)
                .padding(.bottom, 56)
            topticketView
            travelTypeView
            travelPeopleView
            Spacer()
            Button {
                store.send(.tapmakeTicket)
            } label: {
                Text("티켓 생성하기")
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(store.isFormComplete ? .main : .gray2)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
            }
            .padding(.horizontal,16)
            .disabled(!store.isFormComplete)
            
        }
        .applyBackground(color: .background)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("여행 추가")
                    .foregroundStyle(.white)
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    store.send(.tapbackButton)
                } label: {
                    Image(systemName: "chevron.backward")
                        .foregroundStyle(.white)
                }
            }
            
        }
        .sheet(item: $store.scope(state: \.bottomSheet, action: \.bottomSheet)) { bottomSheetStore in
            switch bottomSheetStore.case {
            case let .departureSelection(store):
                SpotSelectionView(store: store)
                    .applyBackground(color: .modal)
                    .presentationDetents([
                        .fraction(0.3)])
            case let .traveTypeSeleciton(store):
                KeywordSelectionView(store: store)
                    .applyBackground(color: .modal)
                    .presentationDetents([.fraction(0.45)])
            case let .dateSelection(store):
                DateSelectionView(store: store)
                    .applyBackground(color: .modal)
                    .presentationDetents([.fraction(0.5 )])
            }
        }
        
    }
    
    var topticketView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 40) {
                VStack(spacing: 6) {
                    Text(store.departureSpot?.upperString ?? "출발지 선택")
                        .font(.system(size: 12))
                    Text(store.departureSpot?.rawValue ?? "출발")
                        .font(.system(size: 25, weight: .semibold))
                }.foregroundStyle(store.departureSpot != nil ? .white : .gray4)
                Image(systemName: "airplane")
                    .foregroundColor(store.departureSpot != nil ? .main : .gray4)
                VStack(spacing: 6){
                    Text(store.arrivialSpot?.upperString ?? "도착지 선택")
                        .font(.system(size: 12))
                    Text(store.arrivialSpot?.rawValue ?? "도착")
                        .font(.system(size: 25, weight: .semibold))
                        .fontWeight(.bold)
                }.foregroundStyle(store.departureSpot != nil ? .white : .gray4)
            }
            .frame(width: 330,height: 130)
            .background(.gray1)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .onTapGesture {
                store.send(.showDepartuare)
            }
            DottedLine()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [2]))
                .frame(width: 312, height: 1)
                .foregroundStyle(Color.gray2)
            Button (action: {
                store.send(.showDateSelection)
            }){
                HStack {
                    Text(store.startDate?.ticketformat ?? "YYYY-MM-DD")
                        .foregroundStyle(store.startDate != nil ? .white : .gray4)

                    Text("-")
                        .foregroundStyle((store.startDate != nil) ? .main : .gray)
                    Text(store.endDate?.ticketformat ?? "YYYY-MM-DD")
                        .foregroundStyle(store.startDate != nil ? .white : .gray4)
                }.font(.system(size: 17,weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 330,height: 95)
                    .background(.gray1)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
    var travelTypeView: some View {
        HStack {
            Image(systemName: "ellipsis.message")
                .resizable()
                .frame(width: 19, height: 19)
                .foregroundStyle(store.keywords == nil ? .gray4 : .main)
            Text(store.keywords?.joined(separator: ", ") ?? "여행의 유형을 선택해주세요.")
                .font(.system(size: 17,weight: .semibold))
                .foregroundStyle(store.keywords == nil ? .gray4 : .white)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(store.keywords == nil ? .gray4 : .main)
        }
        .padding(.leading, 26)
        .padding(.trailing,23)
        .frame(width: 330, height: 80)
        .background(.gray1)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture {
            store.send(.showkeywords)
        }
    }
    var travelPeopleView: some View {
        HStack {
            Image(systemName: "person.crop.circle.badge.plus")
            Text("함께할 친구를 초대해주세요.")
                .font(.system(size: 17,weight: .semibold))
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding(.leading, 26)
        .padding(.trailing,23)
        .frame(width: 330, height: 80)
        .background(Color.gray1)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
}


#Preview {
    NavigationStack{
        Spacer().frame(height: 44)
        AddTicketView(store: Store(initialState: AddTicketFeature.State(), reducer: {
            AddTicketFeature()
        }))
    }
}
