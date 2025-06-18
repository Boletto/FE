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
                Spacer()
                    .frame(maxHeight: 40)
                headerSectionView
                Spacer()
                topticketView
                travelTypeView
                    .padding(.horizontal,32)
                travelPeopleView
                    .padding(.horizontal,32)
                Spacer()
          
                createButton
                 
            }.padding(.bottom,8)
          
            if store.bottomSheet != nil {
                Color.black.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
        .sheet(item: $store.scope(state: \.bottomSheet, action: \.bottomSheet)) { bottomSheetStore in
            switch bottomSheetStore.case {
            case let .departureSelection(store):
                SpotSelectionView(store: store)
                    .applyBackground(color: .modal)
                    .presentationDetents([
                        .fraction(0.36), .fraction(0.45)])
            case let .traveTypeSeleciton(store):
                KeywordSelectionView(store: store)
                    .applyBackground(color: .modal)
                    .presentationDetents([.fraction(0.46), .fraction(0.65)])
            case let .dateSelection(store):
                DateSelectionView(store: store)
                    .applyBackground(color: .modal)
                    .presentationDetents([.fraction(0.55 ), .fraction(0.65)])
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
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.gray5Color)
                .customTextStyle(.body1)
                .frame(maxWidth: .infinity) // 부모 크기 제한 해제
                .fixedSize(horizontal: false, vertical: true) // 세로로 확장 가능
        }
    }
    private var topticketView: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.gray1)
                HStack(spacing: 0) {
                    // 출발지
                    VStack(spacing: 11) {
                        Text(store.departureSpot?.spot.name ?? "출발지 선택")
                            .font(.system(size: 12))
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Text(store.departureSpot?.spot.upperString ?? "출발")
                            .customTextStyle(.pageTitle)
                            .multilineTextAlignment(.center)
                    }
                    .foregroundStyle(store.departureSpot != nil ? .white : .gray4)
                    .frame(maxWidth: .infinity) // 너비 균등 분배, 왼쪽 정렬

                    // 비행기 아이콘
                    Image("airplane")
                        .renderingMode(store.departureSpot != nil ? .original : .template)
                        .foregroundColor(store.departureSpot != nil ? nil : .gray4)
                        .frame(width: 24, height: 24) // 크기 고정
                        .padding(.horizontal, 16) // 아이콘 좌우 간격 추가

                    VStack(spacing: 11) {
                        Text(store.arrivialSpot?.spot.name ?? "도착지 선택")
                            .font(.system(size: 12))
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Text(store.arrivialSpot?.spot.upperString ?? "도착")
                            .customTextStyle(.pageTitle)
                            .multilineTextAlignment(.center)
                    }
                    .foregroundStyle(store.arrivialSpot != nil ? .white : .gray4)
                    .frame(maxWidth: .infinity) // 너비 균등 분배, 오른쪽 정렬
                }
            }.frame(minHeight: 128, maxHeight: 152)
            .overlay(alignment: .bottom) {
            DottedLine()
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [2]))
                .frame( height: 2)
                .foregroundStyle(Color.gray2)
                .padding(.horizontal,16)
            }
            .onTapGesture {
                store.send(.user(.showDepartuare))
            }
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                       .fill(.gray1)
                       .clipShape(RoundedRectangle(cornerRadius: 16))
                HStack(spacing:20) {
                    Text(store.startDate?.ticketformat ?? "YYYY-MM-DD")
                        .foregroundStyle(store.startDate != nil ? .gray6 : .gray4)
                    
                    Text("-")
                        .foregroundStyle((store.startDate != nil) ? .main : .gray4)
                    Text(store.endDate?.ticketformat ?? "YYYY-MM-DD")
                        .foregroundStyle(store.startDate != nil ? .gray6 : .gray4)
                }.customTextStyle(.subheadline)
            }.frame(minHeight: 96, maxHeight: 120)
            .onTapGesture {
                store.send(.user(.showDateSelection))
            }
         
        }.padding(.horizontal,32)
    }
    private var travelTypeView: some View {
        ZStack  {
            RoundedRectangle(cornerRadius: 16)
                .fill(.gray1)
            HStack(spacing: 10) {
                Image(systemName: "ellipsis.message")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15)
                    .foregroundStyle(store.keywords == nil ? .gray4 : .main)
                Text(store.keywords?.map{$0.koreanString}.joined(separator: ", ") ?? "여행의 유형을 선택해주세요.")
                    .lineLimit(1)
                    .font(.system(size: 17,weight: .regular))
                    .foregroundStyle(store.keywords == nil ? .gray4 : .white)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(store.keywords == nil ? .gray5 : .main)
            }     .padding(.leading, 26)
                .padding(.trailing,23)
        }
        .frame(maxHeight: 80)
        .onTapGesture {
            store.send(.user(.showkeywords))
        }
    }
    private var travelPeopleView: some View {
        ZStack  {
            RoundedRectangle(cornerRadius: 16)
                .fill(.gray1)
            HStack(spacing: 10) {
                Image(systemName: "person.crop.circle.badge.plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16)
                    .foregroundStyle(store.keywords == nil ? .gray4 : .main)
                Text(store.friends?.map(\.nickname).joined(separator: ", ") ??  "함께할 친구를 초대해주세요.")
                    .foregroundStyle(store.friends == nil ? .gray4 : .white)
                    .font(.system(size: 17,weight: .regular))
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(store.friends == nil ? .gray4 : .main)
            }
            .padding(.leading, 26)
            .padding(.trailing,23)
        }
        .frame(maxHeight: 80)
        .onTapGesture {
            store.send(.user(.showfriends))
        }
    }
    private var createButton: some View {
        Button {
            store.send(.user(.tapmakeTicket))
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
