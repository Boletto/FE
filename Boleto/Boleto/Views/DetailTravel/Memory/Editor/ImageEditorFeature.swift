import ComposableArchitecture
import SwiftUI
import MetalKit

@Reducer
struct ImageEditorFeature {
    @ObservableState
    struct State: Equatable {
        let originalImage: UIImage
        var filteredImage: UIImage?
        var croppedImage: UIImage?
        var isPressOriginal: Bool = false
        var allfilters: [Filter] = []
        var selectedFilter: Filter?
        var thumbnails: [Filter: UIImage] = [:]
        var isSliderVisible = false
        var sliderValue: Double = 0
        var textureID: UUID? = nil

        var isProcessingFilter: Bool = false
    }
    
    enum Action: BindableAction,Equatable {
        case binding(BindingAction<State> )
        case dismiss
        case fetchAllFilter
        case selectFilter(Filter)
        case changeFilterImage(UIImage)
        case doCropImage(CGRect,CGSize)
        case setFilters([Filter])
        case fetchThumbnails
        case cropComplete(UIImage)
        case applyFilterWithIntensity
        case thumbnailLoaded(Filter, UIImage)
        
        case ttiRecord(String,String)
        case setProcessingState(Bool)
    }
    
    @Dependency(\.metalFilterClient) var metalFilterClient
    @Dependency(\.ttiClient) var ttiClient
    private enum CancelID {
        case sliderUpdate
        case filterProcessing
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.sliderValue):
                guard state.selectedFilter != nil, !state.isProcessingFilter else { return .none }
                return .run { [slider = state.sliderValue] send in
                    await send(.setProcessingState(true))
                                       let filterImage = try await metalFilterClient.updateIntensity(Float(slider))
                                       await send(.changeFilterImage(filterImage))
                                       await send(.setProcessingState(false))
                  }
                .debounce(id: CancelID.sliderUpdate, for: 0.05, scheduler: DispatchQueue.main)
                     .cancellable(id: CancelID.filterProcessing)
            case .binding:
                return .none
            case .applyFilterWithIntensity:
                     guard let filter = state.selectedFilter,
                           !state.isProcessingFilter else { return .none }
                     
                     return .run { [originalImage = state.originalImage, sliderValue = state.sliderValue] send in
                         await send(.setProcessingState(true))
                         let filterImage = try await metalFilterClient.applyFilter(
                            originalImage.resize(targetSize: CGSize(width:256,height:256)),
                             filter.metalFunction,
                             Float(sliderValue)
                         )
                         await send(.changeFilterImage(filterImage))
                         await send(.setProcessingState(false))
                     }
                     .cancellable(id: CancelID.filterProcessing)
            case .dismiss:
                return .none
            case .setProcessingState(let isProcessing):
                            state.isProcessingFilter = isProcessing
                            return .none
                            
            case .fetchAllFilter:
                return .run { send in
                    let filters = try await metalFilterClient.getAllFilters()
                    await send(.setFilters(filters))
                }
                
            case let .setFilters(filters):
                state.allfilters = [Filter.original] + filters
                state.thumbnails = [Filter.original: state.originalImage]
                return .run {send in
                    await send(.fetchThumbnails)
                }
                
            case let .selectFilter(filter):
                state.selectedFilter = filter
                state.sliderValue = Double(filter.defaultIntensity)
                state.isSliderVisible = true
                if filter.metalFunction == "" {
                       state.isSliderVisible = false
                       state.filteredImage = nil
                       return .none
                   } else {
                       state.isSliderVisible = true
                       return .run { [originalImage = state.originalImage] send in
                           await send(.setProcessingState(true))
                                                  let startTime = CFAbsoluteTimeGetCurrent()
                                                  try await metalFilterClient.setupFilter(originalImage, filter.metalFunction)
                                                  let filterImage = try await metalFilterClient.updateIntensity(filter.defaultIntensity)
                                                  await send(.changeFilterImage(filterImage))
                                                  await send(.setProcessingState(false))
                                                  let endTime = CFAbsoluteTimeGetCurrent()
                                                  let processingTime = (endTime - startTime) * 1000
//                                                  await send(.ttiRecord("Filter", "Applied: \(processingTime)ms"))
                       }                    .cancellable(id: CancelID.filterProcessing)

                   }
            case let .changeFilterImage(image):
                state.filteredImage = image
                return .none
            case .fetchThumbnails:
                return .run {[image = state.originalImage, filters = state.allfilters] send in
                    let startTime = CFAbsoluteTimeGetCurrent()
                    let filtersExceptOriginal = filters.dropFirst() // 첫 번째 요소(Original) 제외
                    //MARK: DownSampling후 필터입혔더니 필터가 왜곡됨. 리사이징? -> 썸네일에 필터가 안입혀짐...
                    let batchSize = 3
                    let filterBatches = Array(filtersExceptOriginal).chunked(into: batchSize)
                    for batch in filterBatches {
                        try await withThrowingTaskGroup(of: (Filter, UIImage?).self) { group in
                            for filter in batch {
                                group.addTask {
                                    let filtered = try await metalFilterClient.applyFilter(
                                        image,
                                        filter.metalFunction,
                                        filter.defaultIntensity
                                    )
                                    return (filter, filtered)
                                }
                            }
                            
                            for try await (filter, filtered) in group {
                                if let filtered = filtered {
                                    await send(.thumbnailLoaded(filter, filtered))
                                }
                            }
                        }}
                    let endTime = CFAbsoluteTimeGetCurrent()
                         let totalTime = (endTime - startTime) * 1000
                         
                    await send(.ttiRecord("Filter", "Thumbnails: \(totalTime)ms"))
                }
            case let .thumbnailLoaded(filter, image):
                state.thumbnails[filter] = image
                return .none

                
            case .doCropImage(let rect, let imagesize):
                let cropImage = cropImage(image: state.filteredImage ?? state.originalImage, cropRect: rect, imageViewSize: imagesize)
                return .run { send in
                    await send(.cropComplete(cropImage))
                }
                .throttle(id: "cropOperation", for: 1.0, scheduler: DispatchQueue.main, latest: false)
            case .cropComplete:
                return .none
            case .ttiRecord(let event,let details):
                return .run {send in
                    try await ttiClient.postEvent(event, details)
                }
            }
        }
    }
    
    private func cropImage(image: UIImage, cropRect: CGRect, imageViewSize: CGSize) -> UIImage {
        //이미지 방향을 정규화 어떤 방향이든 up방향으로 만들어서하자.
        let normalizedImage: UIImage
        if image.imageOrientation != .up {
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            image.draw(in: CGRect(origin: .zero, size: image.size))
            normalizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
            UIGraphicsEndImageContext()
        } else {
            normalizedImage = image
        }
        
        //이미지와 뷰의 비율을 정확하게 계산.
        let viewRatio = imageViewSize.width / imageViewSize.height
        let imageRatio = normalizedImage.size.width / normalizedImage.size.height
        
        let scale: CGFloat
        if viewRatio > imageRatio {
            // 이미지가 뷰보다 세로가 길때
            scale = normalizedImage.size.height / imageViewSize.height
        } else {
            // 이미지가 뷰보다 가로가 길때
            scale = normalizedImage.size.width / imageViewSize.width
        }
        
        let scaledCropArea = CGRect(
            x: cropRect.origin.x * scale,
            y: cropRect.origin.y * scale,
            width: cropRect.size.width * scale,
            height: cropRect.size.height * scale
        )
        
        guard let cgImage = normalizedImage.cgImage?.cropping(to: scaledCropArea) else { return image }
        return UIImage(cgImage: cgImage)
    }
}
