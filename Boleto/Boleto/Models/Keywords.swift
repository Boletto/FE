//
//  Keywords.swift
//  Boleto
//
//  Created by Sunho on 9/5/24.
//

import SwiftUI

enum Keywords: String  {
    case luxry, pilgrimage, couple, staycation, slowtravel
    case fandom, foodTour, shopping, sightseeing, workshop
    case activity, adventure, walking, backpacking,exercise, friendship
    case family, graduationTrip, heritageSite, solo, ruralTravel, volunteering
    
    var regularfont: FontName {
        switch self {
        case .fandom, .foodTour, .shopping, .sightseeing, .workshop:
            return .sbfont
        case .activity, .adventure, .walking, .backpacking, .exercise, .friendship:
            return .partifont
        case .family, .graduationTrip, .heritageSite, .solo, .ruralTravel, .volunteering:
            return .ogfont
        case .luxry, .pilgrimage, .couple, .staycation, .slowtravel:
            return .cafefont
        }
    }
    var boldfont: FontName {
        switch self {
        case .fandom, .foodTour, .shopping, .sightseeing, .workshop:
            return .sbboldFont
        case .activity, .adventure, .walking, .backpacking, .exercise, .friendship:
            return .partifont
        case .family, .graduationTrip, .heritageSite, .solo, .ruralTravel, .volunteering:
            return .ogfont
        case .luxry, .pilgrimage, .couple, .staycation, .slowtravel:
            return .cafefont
        }
    }
}
