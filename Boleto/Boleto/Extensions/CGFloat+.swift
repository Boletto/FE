//
//  Boleto
//
//  Created by Sunho on 12/3/24.
//

import Foundation

extension CGFloat {
    func roundedToDecimalPlaces(_ places: Int) -> String {
        String(format: "%.\(places)f", self)
    }
}
