//
//  ExtensionRevenueCat.swift
//  Elixir
//
//  Created by Tatyana Buinitskaya on 29.04.2024.
//

import Foundation
import RevenueCat
import StoreKit

/* Some methods to make displaying subscription terms easier */
extension Package {
    var terms: String {
        if let intro = self.storeProduct.introductoryDiscount {
            if intro.price == 0 {
                return "\(intro.subscriptionPeriod.periodTitle) free trial"
            } else {
                return "\(self.localizedIntroductoryPriceString!) for \(intro.subscriptionPeriod.periodTitle)"
            }
        } else {
            return "Unlocks Premium"
        }
    }
}

extension SubscriptionPeriod {
    var durationTitle: String {
        switch self.unit {
        case .day: return NSLocalizedString("day", comment: "")
        case .week: return NSLocalizedString("week", comment: "")
        case .month: return NSLocalizedString("month", comment: "")
        case .year: return NSLocalizedString("year", comment: "")
        @unknown default: return "Unknown"
        }
    }

    var periodTitle: String {
        let periodString = "\(self.value) \(self.durationTitle)"
        let pluralized = self.value > 1 ?  periodString + "s" : periodString
        return pluralized
    }
}
