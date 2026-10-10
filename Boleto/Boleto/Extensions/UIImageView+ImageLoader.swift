import UIKit
import ComposableArchitecture

extension UIImageView {
    private static var storeKey = 0
    private var store: StoreOf<ImageLoaderFeature>? {
        get { objc_getAssociatedObject(self, &Self.storeKey) as? StoreOf<ImageLoaderFeature> }
        set { objc_setAssociatedObject(self, &Self.storeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    func setImage(from url: URL, targetSize: CGSize? = nil) {
        if store == nil {
            store = Store(initialState: ImageLoaderFeature.State()) {
                ImageLoaderFeature()
            }
        }
        
        guard let store = store else { return }
        
        let viewStore = ViewStore(store, observe: { $0 })
        
        // 이미지가 캐시에 있는 경우
        if let cachedImage = viewStore.imageCache[url] {
            self.image = cachedImage
            return
        }
        
        // 로딩 중인 경우
        if viewStore.loadingStates[url] == true {
            return
        }
        
        // 에러가 있는 경우
        if let error = viewStore.errorStates[url] {
            print("이미지 로드 실패: \(error)")
            return
        }
        
        // 이미지 로드 시작
        viewStore.send(.loadImage(url, targetSize))
        
        // 상태 관찰
        Task {
            for await _ in viewStore.publisher {
                if let image = viewStore.imageCache[url] {
                    await MainActor.run {
                        self.image = image
                    }
                    break
                }
            }
        }
    }
    
    func cancelImageLoad() {
        store = nil
    }
} 