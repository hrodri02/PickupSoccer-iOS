//
//  Day.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 2/15/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import Foundation

struct Day: Equatable {
    let date: Date
    let number: String
    var isSelected: Bool
    let isWithinDisplayedMonth: Bool
    
    static func == (lhs: Day, rhs: Day) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.compare(lhs.date, to: rhs.date, toGranularity: .day) == .orderedSame &&
               lhs.number == rhs.number &&
               lhs.isSelected == rhs.isSelected &&
               lhs.isWithinDisplayedMonth == rhs.isWithinDisplayedMonth
    }
}
