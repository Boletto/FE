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
        ZStack {
            VStack(spacing: 12) {
                headerSectionView
                    .padding(.top,40)
                Spacer()
                topticketView
                travelTypeView
                    .padding(.horizontal,32)
                travelPeopleView
                    .padding(.horizontal,32)
                Spacer().frame(maxHeight: 48)
                createButton
            }
            if store.bottomSheet != nil {
                Color.black.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .applyBackground(color: .background)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(store.mode == .add ? "여행 추가" : "여행 편집")
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
        .alert($store.scope(state: \.alert, action: \.alert))
        .sheet(item: $store.scope(state: \.bottomSheet, action: \.bottomSheet)) { bottomSheetStore in
            switch bottomSheetStore.case {
            case let .departureSelection(store):
                SpotSelectionView(store: store)
                    .applyBackground(color: .modal)
                    .presentationDetents([
                        .fraction(0.35)])
            case let .traveTypeSeleciton(store):
                KeywordSelectionView(store: store)
                    .applyBackground(color: .modal)
                    .presentationDetents([.fraction(0.45)])
            case let .dateSelection(store):
                DateSelectionView(store: store)
                    .applyBackground(color: .modal)
                    .presentationDetents([.fraction(0.55 )])
            case let .friendSelection(store):
                FriendSelectionView(store: store)
                    .presentationDetents([.fraction(1.0)])
            }
        }
        
    }
    private var headerSectionView: some View {
        VStack(spacing: 20) {
            Text(store.mode == .add ? "여행을 떠날 준비 되셨나요?" :"여행 계획이 변경되셨나요?")
                .foregroundStyle(.gray6)
                .customTextStyle(.title)
            Text(store.mode == .add ? "여행 정보를 입력하고, 함께하는 친구를 초대해\n우리들만의 추억을 담은 티켓을 만들어보세요" : "여행 정보를 수정하고, 함께하는 친구를 편집해\n변경된 일정에 맞는 티켓을 만들어보세요")
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.gray5Color)
                .customTextStyle(.body1)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    private var topticketView: some View {
        VStack(spacing: 0) {
            HStack {
       
                VStack(spacing: 11) {
                    Text(store.departureSpot?.spot.name ?? "출발지 선택")
                        .font(.system(size: 12))
                    Text(store.departureSpot?.spot.upperString ?? "출발")
                        .customTextStyle(.pageTitle)
                }.foregroundStyle(store.departureSpot != nil ? .white : .gray4)
                Spacer().frame(width: 36)
                Image("airplane")
                    .renderingMode(store.departureSpot != nil ? .original : .template)
                    .foregroundColor(store.departureSpot != nil ? nil : .gray4)
                Spacer().frame(width: 36)
                VStack(spacing: 11){
                    Text(store.arrivialSpot?.spot.name ?? "도착지 선택")
                        .font(.system(size: 12))
                    Text(store.arrivialSpot?.spot.upperString ?? "도착")
                        .customTextStyle(.pageTitle)
                }.foregroundStyle(store.departureSpot != nil ? .white : .gray4)
             
              
            }
            .frame(maxWidth: .infinity)
            .frame(height: 130)
            .background(.gray1)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(alignment: .bottom) {
                DottedLine()
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [2]))
                    .frame(width: 312, height: 2)
                    .foregroundStyle(Color.gray2)
            }
            .onTapGesture {
                store.send(.showDepartuare)
            }

            Button (action: {
                store.send(.showDateSelection)
            }){
                HStack(spacing:20) {
                    Text(store.startDate?.ticketformat ?? "YYYY-MM-DD")
                        .foregroundStyle(store.startDate != nil ? .gray6 : .gray4)
                    
                    Text("-")
                        .foregroundStyle((store.startDate != nil) ? .main : .gray4)
                    Text(store.endDate?.ticketformat ?? "YYYY-MM-DD")
                        .foregroundStyle(store.startDate != nil ? .gray6 : .gray4)
                }
                .customTextStyle(.subheadline)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
                .frame(height: 95)
                .background(.gray1)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }.padding(.horizontal,32)
    }
    private var travelTypeView: some View {
        HStack(spacing: 16) {
            Image(systemName: "ellipsis.message")
                .resizable()
                .frame(width: 19, height: 19)
                .foregroundStyle(store.keywords == nil ? .gray4 : .main)
            Text(store.keywords?.map{$0.koreanString}.joined(separator: ", ") ?? "여행의 유형을 선택해주세요.")
                .font(.system(size: 17,weight: .regular))
                .foregroundStyle(store.keywords == nil ? .gray4 : .white)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(store.keywords == nil ? .gray5 : .main)
        }
        .padding(.leading, 26)
        .padding(.trailing,23)
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(.gray1)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture {
            store.send(.showkeywords)
        }
    }
    private var travelPeopleView: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.plus")
                .resizable()
                .frame(width: 19, height: 19)
                .foregroundStyle(store.keywords == nil ? .gray4 : .main)
            Text(store.friends?.map(\.nickname).joined(separator: ", ") ??  "함께할 친구를 초대해주세요.")
                .foregroundStyle(store.friends == nil ? .gray4 : .white)
                .font(.system(size: 17,weight: .semibold))
                .lineLimit(1)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(store.friends == nil ? .gray4 : .main)
        }
        .padding(.leading, 26)
        .padding(.trailing,23)
        .frame(maxWidth: .infinity)
        .frame( height: 80)
        .background(Color.gray1)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture {
            store.send(.showfriends)
        }
    }
    private var createButton: some View {
        Button {
            store.send(.tapmakeTicket)
        } label: {
            Text(store.mode == .add ? "티켓 생성하기" : "편집 완료하기")
                .customTextStyle(.normal)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(store.isFormComplete ? .main : .gray2)
                .clipShape(RoundedRectangle(cornerRadius: 30))
        }
        .padding(.horizontal,16)
        .disabled(!store.isFormComplete)
    }
    
}


#Preview {
    NavigationStack{
        
        AddTicketView(store: Store(initialState: AddTicketFeature.State(mode: .add, friends: MemberModel.dummyList), reducer: {
            AddTicketFeature()
        }))
    }
}
