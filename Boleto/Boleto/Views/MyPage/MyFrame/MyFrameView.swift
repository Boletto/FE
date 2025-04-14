//
//  MyFrameView.swift
//  Boleto
//
//  Created by Sunho on 10/3/24.
//

import SwiftUI
import SwiftData

struct MyFrameView: View {
    @Query(FetchDescriptor<FrameData>()) var frames: [FrameData]
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading,spacing: 10) {
                    Group {
                        Text("나의 프레임 ").foregroundStyle(.white) +
                        Text("\(frames.count)" ).foregroundStyle(.main) +
                        Text("개").foregroundStyle(.white)
                    }
                    .customTextStyle(.title)
                    Text("여행을 통해 지역별 네컷 프레임을 모아보세요.")
                        .customTextStyle(.body1)
                        .foregroundStyle(.gray5)
                }
                Spacer()
            }
            .padding(.top, 40)
            .padding(.bottom, 16)
            Spacer()
            frameGridView
            Spacer()
            
        }
        .padding(.horizontal,32)
    }
    @MainActor
    private var frameGridView: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 24, content: {
                ForEach(frames) { frame in
                    ZStack {
                        AsyncImageView(urlString: frame.frameURL, targetSize: CGSize(width: 800, height: 800), imagetype: .image)
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
                    }.overlay {
                        if frame.frameCode == "FA02"{
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray2, lineWidth: 1)
                        }
                    }
                }
                Spacer()
            }
            ).padding(.horizontal, 18)
                .padding(.vertical, 24)
        }
    }
    
}

#Preview {
    let mockFrames = [
        
    ]
    MyFrameView()
}

