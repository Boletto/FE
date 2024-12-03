//
//  MyFrameView.swift
//  Boleto
//
//  Created by Sunho on 10/3/24.
//

import SwiftUI
import SwiftData
import Kingfisher

struct MyFrameView: View {
    @Query(FetchDescriptor<FrameData>()) var frames: [FrameData]
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading,spacing: 10) {
                    Group {
                        Text("나의 프레임").foregroundStyle(.white) +
                        Text("\(frames.count)" ).foregroundStyle(.main)
                    }
                    .customTextStyle(.title)
                    Text("여행을 통해 지역별 네컷 프레임을 모아보세요.")
                        .customTextStyle(.body1)
                        .foregroundStyle(.gray5)
                }
                Spacer()
            }
            .padding(.vertical, 16)
            frameGridView
                
        }
        .padding(.horizontal,32).applyBackground(color: .background)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("나의 여행네컷")
                    .foregroundStyle(.white)
            }
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: "chevron.backward")
                        .foregroundStyle(.white)
                })
            }
        }
    }
    @MainActor
    private var frameGridView: some View {
        ZStack(alignment:.top) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray1)
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 24, content: {
                    ForEach(frames) { frame in
                        ZStack {
                            KFImage.url(URL(string: frame.frameURL))
                                .resizable()
                                .frame(width: 134,height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                            VStack(spacing: 6) {
                                HStack(spacing: 6) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(.gray1)
                                        .frame(width: 55,height: 55)
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(.gray1)
                                        .frame(width: 55,height: 55)
                                }
                                HStack(spacing: 6) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(.gray1)
                                        .frame(width: 55,height: 55)
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(.gray1)
                                        .frame(width: 55,height: 55)
                                }
                            }.padding(.horizontal, 8)
                                .padding(.bottom,24)
                        }
                    }
                }
                ).padding(.horizontal, 18)
                    .padding(.vertical, 24)
            }
        }.frame(maxHeight: .infinity)
    }
    
}

#Preview {
    let mockFrames = [
        
    ]
    MyFrameView()
}

