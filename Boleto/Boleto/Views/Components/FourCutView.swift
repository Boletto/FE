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
        GeometryReader { geo in
            let screenWidth = Int(geo.size.width)
            let padding = CGFloat(screenWidth / 15)
            let imageSize = padding * 6
            VStack(spacing: padding) {
                HStack(spacing: padding) {
                    KFImage.url(URL(string: data.picturesURL[0]))
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageSize, height: imageSize)
                        .clipShape(RoundedRectangle(cornerRadius: isSmallMode ? 10 : 5))
                    KFImage.url(URL(string: data.picturesURL[1]))
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageSize, height: imageSize)
                        .clipShape(RoundedRectangle(cornerRadius: isSmallMode ? 10 : 5))

                }
                HStack(spacing:  padding) {
                    KFImage.url(URL(string: data.picturesURL[2]))
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageSize, height: imageSize)
                        .clipShape(RoundedRectangle(cornerRadius: isSmallMode ? 10 : 5))

                    KFImage.url(URL(string: data.picturesURL[3]))
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageSize, height: imageSize)
                        .clipShape(RoundedRectangle(cornerRadius: isSmallMode ? 10 : 5))
                }
            }
            .padding(.all, padding)
            .padding(.bottom, padding * 2)
            .background(
                KFImage.url(URL(string: frameURL))
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: isSmallMode ? 20 : 10))
            )
            .onAppear {
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


