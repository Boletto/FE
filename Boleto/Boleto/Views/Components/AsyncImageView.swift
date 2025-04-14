import SwiftUI

enum AsyncImageType {
    case image
    case sticker
}


struct AsyncImageView: View {
    let urlString: String
    let targetSize: CGSize?
    let imagetype: AsyncImageType
    @State private var image: UIImage?
    @State private var isLoading = false
    @State private var error: String?
    
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
                }
            } else if let error = error {
                Text(error)
                    .foregroundColor(.red)
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        isLoading = true
        error = nil
        guard let url = URL(string: urlString) else {
            self.error = "Invalid URL"
            return
        }
        do {
            image = try await ImageLoader.shared.loadImage(from: url, targetSize: targetSize, isSticker:  imagetype == .sticker)
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
}

