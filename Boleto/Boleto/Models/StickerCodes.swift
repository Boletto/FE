//
//  StickerType.swift
//  Boleto
//
//  Created by Sunho on 9/27/24.
//

import Foundation
enum StickerCodes: String, CaseIterable {
    case bs01 = "BS01"
    case bs02 = "BS02"
    case bs03 = "BS03"
    case bs04 = "BS04"
    case bs05 = "BS05"
    case bs06 = "BS06"
    case bs07 = "BS07"
    case bs08 = "BS08"
    case bs09 = "BS09"
    case gn01 = "GN01"
    case gn02 = "GN02"
    case gn03 = "GN03"
    case gn04 = "GN04"
    case gj01 = "GJ01"
    case gj02 = "GJ02"
    case gj03 = "GJ03"
    case gj04 = "GJ04"
    case sl01 = "SL01"
    case sl02 = "SL02"
    case sl03 = "SL03"
    case sl04 = "SL04"
    case sl05 = "SL05"
    case sl06 = "SL06"
    case sl07 = "SL07"
    case sl08 = "SL08"
    case sw01 = "SW01"
    case sw02 = "SW02"
    case sw03 = "SW03"
    case sw04 = "SW04"
    case ys01 = "YS01"
    case ys02 = "YS02"
    case ys03 = "YS03"
    case ys04 = "YS04"
    case jj01 = "JJ01"
    case jj02 = "JJ02"
    case jj03 = "JJ03"
    case jj04 = "JJ04"
    case jj05 = "JJ05"
    case jj06 = "JJ06"
    case jj07 = "JJ07"
    case jj08 = "JJ08"
    case jj09 = "JJ09"
    case st01 = "ST01"
    case st02 = "ST02"
    case st03 = "ST03"
    case st04 = "ST04"
    case st05 = "ST05"
    case st06 = "ST06"
    case st07 = "ST07"
    case st08 = "ST08"
    case st09 = "ST09"
    case st10 = "ST10"
    case st11 = "ST11"
    case st12 = "ST12"
    case sp01 = "SP01"
    
    var koreanString: String {
        switch self {
        case .bs01: return "BIFF 광장"
        case .bs02: return "송도 구름산책로"
        case .bs03: return "해운대 블루라인파크"
        case .bs04: return "범어사"
        case .bs05: return "광안리 대교"
        case .bs06: return "영화의 전당"
        case .bs07: return "해운대 해수욕장"
        case .bs08: return "흰여울마을"
        case .bs09: return "감천문화마을"
        case .gn01: return "경포대"
        case .gn02: return "경포호"
        case .gn03: return "정동진"
        case .gn04: return "주문진해변"
        case .gj01: return "석굴암"
        case .gj02: return "첨성대"
        case .gj03: return "옥산서원"
        case .gj04: return "황룡사지"
        case .sl01: return "경복궁"
        case .sl02: return "여의도 한강공원"
        case .sl03: return "낙산공원"
        case .sl04: return "남산타워"
        case .sl05: return "롯데월드"
        case .sl06: return "광화문광장"
        case .sl07: return "북촌한옥마을"
        case .sl08: return "창덕궁 후원"
        case .sw01: return "월화원"
        case .sw02: return "수원화성"
        case .sw03: return "광교호수공원"
        case .sw04: return "월드컵경기장"
        case .ys01: return "엑스포"
        case .ys02: return "오동도"
        case .ys03: return "검은모래해변"
        case .ys04: return "해상케이블카"
        case .jj01: return "한라산"
        case .jj02: return "별빛공원"
        case .jj03: return "섭지코지"
        case .jj04: return "용암동굴"
        case .jj05: return "카멜리아 힐"
        case .jj06: return "이호테우 해수욕장"
        case .jj07: return "주상절리대"
        case .jj08: return "제주동문시장"
        case .jj09: return "한담해안산책로"
        default:
            return "기본"
        }
    }
    
    static func fromKoreanString(_ koreanString: String) -> StickerCodes? {
        return StickerCodes.allCases.first { $0.koreanString == koreanString }
    }
    
//    static func fromEnglishString(_ english: String) -> StickerImage? {
//        return StickerImage.allCases.first { $0.rawValue == english }
//    }
}
