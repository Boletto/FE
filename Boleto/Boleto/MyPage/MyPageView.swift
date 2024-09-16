//
//  MyPageView.swift
//  Boleto
//
//  Created by Sunho on 9/11/24.
//

import SwiftUI
import ComposableArchitecture
struct MyPageView: View {
    @Bindable var store: StoreOf<MyPageFeature>
    var body: some View {

            VStack(spacing: 0) {
                myProfileTicketView
                    .padding(.top, 20)
                    .padding(.bottom, 15)
                myTravelMemoryViews
                    .padding(.vertical, 15)
                HStack {
                    Text("함께하는 여행")
                        .foregroundStyle(.white)
                        .customTextStyle(.subheadline)
                    Spacer()
                }.padding(.vertical, 15)
                makeListView(text: "친구목록")
                    .padding(.bottom, 10)
                makeListView(text: "초대받은 여행")
                    .onTapGesture {
                        store.send(.invitedTravelsTapped)
                    }
                Spacer()
            }.padding(.horizontal,32)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("마이페이지")
                            .foregroundStyle(.white)
                    }
               
                }
                .applyBackground(color: .background)
    
     
       
        
        
    }
    var myProfileTicketView: some View {
        VStack(alignment: .leading,spacing: 15) {
            Text("나의 프로필")
                .foregroundStyle(.white)
                .customTextStyle(.subheadline)
            ZStack(alignment: .topLeading) {
                Image("settinginfo")
                
                HStack(spacing: 15) {
                    Image("dong")
                        .resizable()
                        .frame(width: 60,height: 60)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 14) {
                            Text("이서노")
                                .customTextStyle(.title)
                            Image(systemName: "chevron.right")
                        }
                        Text("이선호")
                            .customTextStyle(.body1)
                    }.onTapGesture {
                        store.send(.profileTapped)
                    }
                    Spacer()
                }
                .padding(.top,30)
                .padding(.leading,21)
            }.frame(width: 330,height: 180)
        }
    }
    var myTravelMemoryViews: some View {
        VStack(alignment: .leading) {
            Text("여행 수첩")
                .foregroundStyle(.white)
                .customTextStyle(.subheadline)
            HStack(spacing: 15) {
                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray1)
                        .scaledToFit()
                    Image("stamp")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 140,height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .overlay {
                    VStack {
                         HStack {
                             Text("나의 여행 네컷")
                                 .foregroundStyle(.white)
                             Spacer()
                         }
                         Spacer() // Pushes the content to the top-left
                     }
                     .padding(.top, 16)
                     .padding(.leading, 15)
                }
                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray1)
                        .scaledToFit()
                    Image("stamp1")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 140,height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .overlay {
                    VStack {
                         HStack {
                             Text("나의 스티커")
                                 .foregroundStyle(.white)
                             Spacer()
                         }
                         Spacer() // Pushes the content to the top-left
                     }
                     .padding(.top, 16)
                     .padding(.leading, 15)
                }
                .onTapGesture {
                    store.send(.stickersTapped)
                }
            }
            
        }
    }
    func makeListView(text: String) -> some View {
        HStack {
            Text(text)
                .foregroundStyle(.white)
                .customTextStyle(.body1)
            Spacer()
        }
        .padding(.vertical,11)
        .padding(.leading,15)
            .background(RoundedRectangle(cornerRadius: 5).fill(.gray1))
    }
  
}

//#Preview {
//    MyPageView()
//}
