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
    let id: String
    let address: String
    let startDate: String
    let duration: String
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter
    }()
    
    init(game: Game) {
        self.id =  game.id ?? ""
        self.address = game.address ?? ""
        self.startDate = GameViewModel.dateFormatter.string(from: game.timeInterval.start)
        let durationInSecs = Int(game.timeInterval.duration)
        let durationInMins = durationInSecs / 60
        let hours = Int(durationInMins) / 60
        let mins = Int(durationInMins) % 60
        self.duration = "\(hours) h \(mins) m"
    }
}
