//
//  StickerType.swift
//  Boleto
//
//  Created by Sunho on 9/27/24.
//

import Foundation
enum StickerImage: String {
    case letsgo = "LETSGO"
    case gdb = "GDB"
    case hnp = "HNP"
    case gbg = "GBG"
    case nst = "NST"
    case bs = "BS"
    case hello = "HELLO"
    case fly = "FLY"
    case imhere = "IMHERE"
    case itb = "ITB"
    case sl = "SL"
    case hb = "HB"
    case np = "NP"
    case ch = "CH"
    case jc = "JC"
    case bcc = "BCC"
    case welcome = "WELCOME"
    case bubble = "BUBBLE"
    
    var koreanString: String {
        switch self {
        case .letsgo:
            ""
        case .gdb:
            "광안대교"
        case .hnp:
            "한라산 국립공원"
        case .gbg:
            "경복궁"
        case .nst:
            "남산타워"
        case .bs:
            "BIFF 광장"
        case .hello:
            ""
        case .fly:
            ""
        case .imhere:
            ""
        case .itb:
            "이호테우 해수욕장"
        case .sl:
            "석촌호수"
        case .hb:
            "해운대 해수욕장"
        case .np:
            "낙산공원"
        case .ch:
            "카멜리아 힐"
        case .jc:
            "주상절리대"
        case .bcc:
            "영화의 전당"
        case .welcome:
            ""
        case .bubble:
            ""
        }
    }
}
