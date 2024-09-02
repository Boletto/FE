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
                .customTextStyle(.large)
                .padding(.top, 40)
                .padding(.bottom, 4)
            Text("여행 정보를 입력하고, 함께하는 친구를 초대해\n우리들만의 추억을 담은 티켓을 만들어보세요")
                .multilineTextAlignment(.center)
                .customTextStyle(.body2)
                .padding(.bottom, 56)
            topticketView
            travelTypeView
            travelPeopleView
            Spacer()
            Button {
                
            } label: {
                Text("티켓 생성하기")
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal,16)

        }
        .sheet(item: $store.scope(state: \.bottomSheet, action: \.bottomSheet)) { bottomSheetStore in
            switch bottomSheetStore.state {
            case .departureSelection:
                SpotSelectionView()
                    .presentationDetents([
                        .fraction(0.3)])
            case .dateSelection:
                DateSelectionView() {start, end in
                    store.send(.dateSelection(start: start.ticketformat, end: end.ticketformat))
                }
                    .presentationDetents([
                        .fraction(0.6)])
            case .traveTypeSeleciton:
                        KeywordSelectionView(store: bottomSheetStore.scope(state: \.traveTypeSeleciton, action: \.traveTypeSeleciton))
                            .presentationDetents([.fraction(0.45)])
                

            }
        }
    }
    
    var topticketView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 40) {
                VStack(spacing: 6) {
                    Text("출발지 선택")
                        .font(.system(size: 12))
                    Text("출발")
                        .font(.system(size: 25, weight: .semibold))
                }
                Image(systemName: "airplane")
                    .foregroundColor(.gray)
                VStack(spacing: 6){
                    Text("도착지 선택")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text("도착")
                        .font(.system(size: 25, weight: .semibold))
                        .fontWeight(.bold)
                }
            }
            .frame(width: 330,height: 130)
            .background(Color.gray.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .onTapGesture {
                store.send(.showDepartuare)
            }
            DottedLine()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [2]))
                .frame(width: 312, height: 1)
            Button (action: {
                store.send(.showDateSelection)
            }){
                HStack {
                    Text(store.startDate ?? "YYYY-MM-DD")
                    Text("-")
                        .foregroundStyle((store.startDate != nil) ? .main : .gray)
                    Text(store.endDate ?? "YYYY-MM-DD")
                }.font(.system(size: 17,weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 330,height: 95)
                    .background(Color.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
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
        .background(Color.gray.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 10))
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
        .background(Color.gray.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
}
struct DottedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x:0,y:0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
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
