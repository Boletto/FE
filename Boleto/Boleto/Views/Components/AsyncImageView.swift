import SwiftUI

enum AsyncImageType {
    case image
    case sticker
    case fourCut(urls: [String], isLargeMode: Bool)
}


struct AsyncImageView: View {
    let urlString: String
    let targetSize: CGSize?
    let imagetype: AsyncImageType
    @State private var image: UIImage?
    @State private var isLoading = false
    @State private var error: String?
    @State private var fourCutImage: [UIImage] = []
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else if let image = image {
                switch imagetype {
                case .image:
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                case .sticker:
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                case .fourCut(let urls, let isSmallMode):
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipShape(RoundedRectangle(cornerRadius: isSmallMode ? 20 : 10))
                            .clipped()
                        
                        GeometryReader { geo in
                            let screenWidth = geo.size.width
                            let padding = CGFloat(screenWidth / 15)
                            
                            VStack(spacing: padding) {
                                HStack(spacing: padding) {
                                    ForEach(0..<2) { index in
                                        if index < fourCutImage.count {
                                            Image(uiImage: fourCutImage[index])
                                                .resizable()
                                                .aspectRatio(1, contentMode: .fit)
                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                .clipShape(RoundedRectangle(cornerRadius: isSmallMode ? 10 : 5))
                                        }
                                    }
                                }
                                .frame(maxHeight: .infinity)
                                
                                HStack(spacing: padding) {
                                    ForEach(2..<4) { index in
                                        if index < fourCutImage.count {
                                            Image(uiImage: fourCutImage[index])
                                                .resizable()
                                                .aspectRatio(1, contentMode: .fit)
                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                .clipShape(RoundedRectangle(cornerRadius: isSmallMode ? 10 : 5))
                                        }
                                    }
                                }
                                .frame(maxHeight: .infinity)
                            }
                            .padding(.all, padding)
                            .padding(.bottom, padding * 1.5)
                        }
                    }
                    .aspectRatio(0.87, contentMode: .fit)
                }
            } else if let error = error {
                Text(error)
                    .foregroundColor(.red)
            }
        }
        .task {
            switch imagetype {
            case .image:
                await loadImage(isSticker: false)
            case .sticker:
                await loadImage(isSticker: true)
            case .fourCut(let urls, let isLargeMode):
                let (frameImage, fourimages) =  await loadFourCuts(urlString: urlString, urls: urls)
                image = frameImage
                fourCutImage = fourimages
            }
    
        }
    }
    
    private func loadFourCuts( urlString: String,  urls: [String]) async  -> (UIImage?, [UIImage]){
        isLoading = true
        error = nil
        do {
                let (frameImage, fourCutImages) = try await ImageLoader.shared.loadFourCutImages(frameUrl: urlString, imageUrls: urls)
                isLoading = false
                return (frameImage, fourCutImages)
            } catch {
                print("errorrorororo")
                isLoading = false
                return (nil, [])
            }
    }
    
    private func loadImage(isSticker: Bool) async {
        isLoading = true
        error = nil
        guard let url = URL(string: urlString) else {
            self.error = "Invalid URL"
            return
        }
        do {
            image = try await ImageLoader.shared.loadImage(
                        from: url,
                        targetSize: targetSize,
                        isSticker: isSticker
                    )

        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
}

