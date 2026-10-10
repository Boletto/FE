import Foundation

@CasePathable
enum LocationMonitorEvent: Equatable {
    case didEnterFrameRegion(String)
    case didEnterBadgeRegion(StickerCodes)
} 