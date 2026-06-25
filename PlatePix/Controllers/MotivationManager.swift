//
//  MotivationManager.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 20.06.2026.
//

import Foundation

enum MotivationManager {
    static func todaysMotivationIndex() -> Int {
        let dayNumber = Calendar.current.ordinality(
            of: .day,
            in: .year,
            for: Date()
        ) ?? 1

        return (dayNumber - 1) % Motivations.motivations.count
    }
}
