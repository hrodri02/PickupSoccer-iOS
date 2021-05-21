//
//  GameViewModel.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/19/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import Foundation

struct GameViewModel
{
    let address: String
    let startDate: String
    let duration: String
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter
    }()
    
    init(game: GameMO) {
        self.address = game.address ?? ""
        if let start = game.dateInterval?.start {
            self.startDate = GameViewModel.dateFormatter.string(from: start)
        }
        else {
            self.startDate = ""
        }
        
        if let dateInterval = game.dateInterval, let start = dateInterval.start, let end = dateInterval.end {
            let durationInSecs = Int(end.timeIntervalSince1970 - start.timeIntervalSince1970)
            let durationInMins = durationInSecs / 60
            let hours = Int(durationInMins) / 60
            let mins = Int(durationInMins) % 60
            self.duration = "\(hours) h \(mins) m"
        }
        else {
            self.duration = ""
        }
    }
}
