//
//  Keywords.swift
//  Boleto
//
//  Created by Sunho on 9/5/24.
//

import SwiftUI

enum Keywords: String, CaseIterable, Equatable  {
    case luxry = "Luxry"
    case religion = "Religion"
         case date = "Date", relax = "Relax", hotel = "Hotel", slow = "Slow"
    case fandom = "Fandom", food = "Food", shopping = "Shopping", tour = "Tour", workshop = "Workshop", city = "City"
    case activity = "Activity", adventure = "Adventure", onfoot = "On foot", backpacking = "Backpacking",workout = "Workout", friend = "Friend"
    case family = "Family", graduation = "Graduaiton", history = "History", alone = "Alone", volunteer = "Volunteer", country = "Country"
    
    var regularfont: FontName {
        switch self {
        case .fandom, .food, .shopping, .tour, .workshop, .city:
            return .sbfont
        case .activity, .adventure, .onfoot, .backpacking, .workout, .friend:
            return .partifont
        case .family, .graduation, .history, .alone, .volunteer, .country:
            return .ogfont
        case .luxry, .religion, .date, .relax, .slow, .hotel:
            return .cafefont
        }
    }
    var boldfont: FontName {
        switch self {
        case .fandom, .food, .shopping, .tour, .workshop, .city:
            return .sbboldFont
        case .activity, .adventure, .onfoot, .backpacking, .workout, .friend:
            return .partifont
        case .family, .graduation, .history, .alone, .volunteer, .country:
            return .ogfont
        case .luxry, .religion, .date, .relax, .slow, .hotel:
            return .cafefont
        }
    }
    var koreanString: String {
        switch self {
        case .luxry:
            return "럭셔리"
        case .religion:
            return "종교"
        case .date:
            return "데이트"
        case .relax:
            return "휴식"
        case .hotel:
            return "호캉스"
        case .slow:
            return "느린여행"
        case .fandom:
            return "덕질"
        case .food:
            return "식도락"
        case .shopping:
            return "쇼핑"
        case .tour:
            return "관광"
        case .workshop:
            return "워크숍"
        case .city:
            return "도시"
        case .activity:
            return "액티비티"
        case .adventure:
            return "모험"
        case .onfoot:
            return "뚜벅이"
        case .backpacking:
            return "배낭여행"
        case .workout:
            return "운동"
        case .friend:
            return "우정"
        case .family:
            return "가족"
        case .graduation:
            return "졸업여행"
        case .history:
            return "역사"
        case .alone:
            return "나홀로"
        case .volunteer:
            return "봉사"
        case .country:
            return "시골여행"
        }
    }

}
extension Keywords {
    static func fromKoreanString(_ koreanString: String) -> Keywords? {
        switch koreanString {
        case "럭셔리": return .luxry
        case "종교": return .religion
        case "데이트": return .date
        case "휴식": return .relax
        case "호캉스": return .hotel
        case "느린여행": return .slow
        case "덕질": return .fandom
        case "식도락": return .food
        case "쇼핑": return .shopping
        case "관광": return .tour
        case "워크숍": return .workshop
        case "도시": return .city
        case "액티비티": return .activity
        case "모험": return .adventure
        case "뚜벅이": return .onfoot
        case "배낭여행": return .backpacking
        case "운동": return .workout
        case "우정": return .friend
        case "가족": return .family
        case "졸업여행": return .graduation
        case "역사": return .history
        case "나홀로": return .alone
        case "봉사": return .volunteer
        case "시골여행": return .country
        default: return nil
        }
    }
}
