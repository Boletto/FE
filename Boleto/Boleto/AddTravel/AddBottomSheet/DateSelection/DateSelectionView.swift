//
//  DateSelectionView.swift
//  Boleto
//
//  Created by Sunho on 8/31/24.
//

import SwiftUI
import ComposableArchitecture

struct DateSelectionView: View {
    @Bindable var store: StoreOf<DateSelectionFeature>
    var body: some View {
            VStack {
                HStack {
                    Text("여행 일정")
                        .font(.system(size: 17))
                        .foregroundStyle(.white)
                        .padding(.bottom , 48)
                }.padding(.top,30)
                    Spacer()
                headerView
                    .foregroundStyle(.white)
                calendarGridView
                Button {
                    store.send(.sendDate)
                } label: {
                    Text("완료")
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.main)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

            }
            .padding(.horizontal,32)
        
        .gesture(
            DragGesture()

                .onEnded { gesture in
                    if gesture.translation.width < -100 {
                        store.send(.changeMonth( 1))
                    } else if gesture.translation.width > 100 {
                        store.send(.changeMonth(-1))
                    }

                }
        )
    }
    
    // MARK: - 헤더 뷰
    private var headerView: some View {
        VStack {
            HStack {
                Text(store.month, formatter: Self.dateFormatter)
                    .font(.system(size: 17))
                Spacer()
                Button(action: {store.send(.changeMonth(-1))}, label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.white)
                })
                .padding(.trailing,23)
                Button(action: {store.send(.changeMonth(1))}, label: {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.white)
                })
            }
            .padding(.bottom,16)
            HStack {
                ForEach(["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"], id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size: 13, weight: .semibold))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 5)
        }
    }
    
    // MARK: - 날짜 그리드 뷰
    private var calendarGridView: some View {
        let daysInMonth = numberOfDays(in: store.month)
        let firstWeekday = firstWeekdayOfMonth(in: store.month) - 1
        
        return
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(),spacing: 0), count: 7), spacing: 0) {
            ForEach(0..<42) { index in
                if index < firstWeekday || index >= daysInMonth + firstWeekday {
                    Color.clear
                } else {
                    let date = getDate(for: index - firstWeekday + 1)
                    CellView(date: date, isSelected: isDateInRange(date), isStart: isStartDate(date), isEnd: isEndDate(date))
                        .onTapGesture {
                            store.send(.selectDate(date))
                        }
                }
            }
        }

        
    }
    
    // MARK: - 일자 셀 뷰
    private struct CellView: View {
        var date: Date
        var isSelected: Bool
        var isStart: Bool
        var isEnd: Bool
        
        var body: some View {
            let isToday = Calendar.current.isDateInToday(date)
            Text("\(Calendar.current.component(.day, from: date))")
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .background(
                    ZStack {
                        if isSelected {
                            if isStart {
                                ZStack {
                                    CapsuleShape(isLeft: true, radius: 20)
                                        .fill(Color.blue.opacity(0.3))
                                    Circle()
                                        .fill(Color.mainColor)
                                }
                            } else if isEnd {
                                ZStack {
                                    CapsuleShape(isLeft: false, radius: 20)
                                        .fill(Color.blue.opacity(0.3))
                                    Circle()
                                        .fill(Color.mainColor)
                                        
                                }
                            } else {
                                Rectangle()
                                    .fill(Color.blue.opacity(0.3))
                            }
                        }
                    }
                )
                .font(.system(size: isStart || isEnd ? 24 : 20, weight: isStart || isEnd ? .medium : .regular))
                .foregroundColor(isToday ? .main : (isStart || isEnd ? .black : .white))
        }
    }
    
    // MARK: - 내부 메서드
    private func getDate(for day: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: day - 1, to: startOfMonth())!
    }
    
    private func startOfMonth() -> Date {
        let components = Calendar.current.dateComponents([.year, .month], from: store.month)
        return Calendar.current.date(from: components)!
    }
    
    private func numberOfDays(in date: Date) -> Int {
        return Calendar.current.range(of: .day, in: .month, for: date)?.count ?? 0
    }
    
    private func firstWeekdayOfMonth(in date: Date) -> Int {
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        let firstDayOfMonth = Calendar.current.date(from: components)!
        return Calendar.current.component(.weekday, from: firstDayOfMonth)
    }
    
    
    
    private func isDateInRange(_ date: Date) -> Bool {
        guard let start = store.startDate, let end = store.endDate else { return false }
        return date >= start && date <= end
    }
    
    private func isStartDate(_ date: Date) -> Bool {
        return Calendar.current.isDate(date, inSameDayAs: store.startDate ?? Date.distantPast)
    }
    
    private func isEndDate(_ date: Date) -> Bool {
        return Calendar.current.isDate(date, inSameDayAs: store.endDate ?? Date.distantFuture)
    }
}

// MARK: - Static 프로퍼티
extension DateSelectionView {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
}


struct CapsuleShape: Shape {
    let isLeft: Bool
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        if isLeft {
            path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                        radius: radius,
                        startAngle: Angle(degrees: 180),
                        endAngle: Angle(degrees: 270),
                        clockwise: false)
            path.addLine(to: CGPoint(x: rect.maxX , y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                        radius: radius,
                        startAngle: Angle(degrees: 90),
                        endAngle: Angle(degrees: 180),
                        clockwise: false)
        } else {
            path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: radius, startAngle: Angle(degrees: 90), endAngle:  Angle(degrees: 270), clockwise: true)
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x:rect.minX, y: rect.maxY))
        }
        return path
    }
}
