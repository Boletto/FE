//
//  ReceiveFriendView.swift
//  Boleto
//
//  Created by Sunho on 11/16/24.
//

import Foundation
import SwiftUI

struct ReceiveFriendView: View {
    let name: String
    let onAccpet: () -> Void
    let onDecline: () -> Void
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            VStack(spacing: 13) {
                ZStack {
                    Image("inviteFrinedTicket")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    VStack(alignment: .center, spacing: 12) {
                        Text("\(name)님께 친구신청이 왔어요")
                            .customTextStyle(.normal)
                        Text("\(name)님과 친구가 되어\n여행에서 추억을 쌓아보세요!")
                            .multilineTextAlignment(.center)
                            .font(.system(size: 12, weight: .regular))
                        
                    }.padding(.bottom,48)
                }
                HStack(spacing: 20) {
                    Button {
                        onDecline()
                    } label: {
                        Text("거절")
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                                
                            }
                    }
                    Button {
                        onAccpet()
                    } label: {
                        Text("수락")
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.main)
                                
                            }
                        
                        
                    }
                }
            }
            .padding(.horizontal, 56)
        }
    }
}
//#Preview {
//    ReceiveFriendView(name: "선호")
//}
