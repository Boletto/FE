//
//  EditingState.swift
//  Boleto
//
//  Created by Sunho on 12/10/24.
//

import Foundation
enum EditState: Equatable {
    case lockedByOthers
    case lockedByMe
    case unlocked
    var isLocked: Bool {
        switch self {
        case .lockedByOthers, .lockedByMe:
            return true
        case .unlocked:
            return false
        }
    }
}
