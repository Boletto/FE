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
        ScrollView {
            LazyVStack(alignment: .leading) {
                Text("오늘")
                   .customTextStyle(.subheadline)
                   .foregroundStyle(.white)
                   .padding(.leading,31)
                   .padding(.top,40)
                ForEach(Array(store.todayAlarms.enumerated()), id: \.element.alarmId) { index, alarm in
                                            makeAlarmRow(alarmModel: alarm)
                                                .onTapGesture {
                                                    store.send(.tapAlarmRow(alarm))
                                                }
                    if index < store.todayAlarms.count - 1 {
                                              Divider()
                                                  .background(Color.gray2)
                                                  .frame(height: 2)
                                          }
                        }
                Text("지난 알림")
                   .customTextStyle(.subheadline)
                   .foregroundStyle(.white)
                   .padding(.leading,31)
                   .padding(.top,25)
        
                ForEach(Array(store.pastAlarms.enumerated()), id: \.element.alarmId) {index, alarm in
                    makeAlarmRow(alarmModel: alarm)
                        .onTapGesture {
                            store.send(.tapAlarmRow(alarm))
                        }
                    if index < store.todayAlarms.count - 1 {
                                              Divider()
                                                  .background(Color.gray2)
                                                  .frame(height: 2)
                                          }
                }
            }
        }
            .task {
                store.send(.getAllAlarm)
            }
            .background(Color.background.ignoresSafeArea()) // 전체 List 배경 설정
    }
    func makeAlarmRow(alarmModel: AlarmModel ) ->  some View {
        HStack(spacing: 12) {
            Circle()
                .fill(alarmModel.read ? Color.clear : Color.main)
                .frame(width: 5,height: 5)
                .padding(.bottom,50)
            
            HStack(spacing: 0) {
                switch alarmModel.alarmType {
                case .travelTicket:
                    Text(alarmModel.message)
                        .customTextStyle(.body1)
                        .foregroundStyle(alarmModel.read ? .gray4 : .white)
                default:
                    let replaceMessage = alarmModel.message.replacingOccurrences(of: "{value}", with: alarmModel.value).components(separatedBy: " ")
                    let components = alarmModel.message.components(separatedBy: " ")
                    if let valueIndex = components.firstIndex(where: {$0.contains("value")}) {
                        ForEach(Array(replaceMessage.enumerated()),id: \.offset) { index, word in
                            Text("\(word) ")
                                .foregroundStyle(index == valueIndex ? .main : .white)
                        }
                    }
                }
        
            }
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
