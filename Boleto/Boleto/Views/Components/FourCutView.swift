//
//  FourCutView.swift
//  Boleto
//
//  Created by Sunho on 10/1/24.
//

import SwiftUI
import Kingfisher
import ComposableArchitecture
import SwiftData

struct FourCutView: View {
    let data: FourCutItem
    let isSmallMode: Bool
    @State private var frameURL: String = ""
    @Dependency(\.databaseClient.context) private var context
       
    var body: some View {
        VStack {
            HStack(spacing: isSmallMode ? 18 : 2) {
                KFImage.url(URL(string: data.picturesURL[0]))
                    .resizable()
                    .scaledToFit()
                    .frame(width: isSmallMode ? 100 : 52, height: isSmallMode ? 100 : 52)
                    .clipShape(RoundedRectangle(cornerRadius: isSmallMode ? 10 : 5))
                KFImage.url(URL(string: data.picturesURL[1]))
                    .resizable()
                    .scaledToFit()
                    .frame(width: isSmallMode ? 100 : 52, height: isSmallMode ? 100 : 52)
                    .clipShape(RoundedRectangle(cornerRadius: isSmallMode ? 10 : 5))

            }
            HStack(spacing: isSmallMode ? 18 : 2) {
                KFImage.url(URL(string: data.picturesURL[2]))
                    .resizable()
                    .scaledToFit()
                    .frame(width: isSmallMode ? 100 : 52, height: isSmallMode ? 100 : 52)
                    .clipShape(RoundedRectangle(cornerRadius: isSmallMode ? 10 : 5))

                KFImage.url(URL(string: data.picturesURL[3]))
                    .resizable()
                    .scaledToFit()
                    .frame(width: isSmallMode ? 100 : 52, height: isSmallMode ? 100 : 52)
                    .clipShape(RoundedRectangle(cornerRadius: isSmallMode ? 10 : 5))
            }
        }
        .padding(.all, isSmallMode ? 16 : 8)
        .padding(.bottom, isSmallMode ? 40 : 16)
        .background(
            KFImage.url(URL(string: frameURL))
                .resizable()
//                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: isSmallMode ? 20 : 10))
        )
        .onAppear {
            Task {
                do {
                   let framecontext = try context()
                    let findCode = data.frameCode
                    let thisFrame = try framecontext.fetch(FetchDescriptor<FrameData>(predicate: #Predicate<FrameData>{$0.frameCode == findCode}))
                    frameURL = thisFrame[0].frameURL
                } catch {
                    print("Failed to fetch FrameData: \(error)")
                }
            }
        }
    }
}


