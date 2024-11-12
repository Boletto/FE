//
//  NotificationView.swift
//  Boleto
//
//  Created by Sunho on 9/14/24.
//

import SwiftUI
import ComposableArchitecture
struct AlarmsView: View {
    @Bindable var store: StoreOf<AlarmsFeature>
    var body: some View {
        List {
            Section(header: Text("오늘")
                .customTextStyle(.subheadline)
                .foregroundStyle(.white)) {
                ForEach(store.todayAlarms, id: \.alarmId) { alarm in
                    makeAlarmRow(alarmModel: alarm)
                        .listRowBackground(Color.background)  .listRowInsets(EdgeInsets())
                }
            }
                .listSectionSeparator(.hidden)
            Section(header: Text("지난 알림")
                .customTextStyle(.subheadline)
                .foregroundStyle(.white)) {
                ForEach(store.pastAlarms, id: \.alarmId) { alarm in
                    makeAlarmRow(alarmModel: alarm)
                        .listRowBackground(Color.background)
                        .listRowInsets(EdgeInsets())
                }
            }
                .listSectionSeparator(.hidden)
                .padding(.bottom, 24)

        }
        .listStyle(.plain)
        .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("알림")
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {store.send(.tapbackbutton)}, label: {
                        Image(systemName: "chevron.backward")
                            .foregroundStyle(.white)
                    })
                }
            }.applyBackground(color: .background)
            .task {
                store.send(.getAllAlarm)
            }
//        ScrollView {
//            VStack(alignment: .leading) {
//                
//                    Text("오늘 ")
//                        .customTextStyle(.subheadline)
//                        .foregroundStyle(.white)
//                        .padding(.top, 40)
//                        .padding(.leading,32)
//                makeAlarmRow(alarmModel: store.alarms[0])
//                
//            } }.customTextStyle(.subheadline)
//      
//            .task {
//                store.send(.getAllAlarm)
//            }
    }
    func makeAlarmRow(alarmModel: AlarmModel ) ->  some View {
        HStack(spacing: 12) {
            Circle()
                .fill(alarmModel.read ? Color.clear : Color.main)
                .frame(width: 5,height: 5)
                .padding(.bottom,50)
            
            
            Text(alarmModel.message)
                .foregroundStyle(alarmModel.read ? .gray4 : .white)
            Spacer()
            Button {
                
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(alarmModel.read ? .clear :.gray2)
            }
            .padding(.trailing,32)

                
        }    .padding(.leading,16)
            .frame(maxWidth: .infinity)
            .frame(height: 75)
    }
}

#Preview {
    AlarmsView(store: .init(initialState: AlarmsFeature.State(
        todayAlarms: AlarmModel.dummy
    ), reducer: {
        AlarmsFeature()
    }))
}
