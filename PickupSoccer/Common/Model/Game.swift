//
//  Game.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 2/14/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import MapKit

struct Game
{
    var location: CLLocationCoordinate2D
    var dateInterval: DateInterval
    
    init() {
        dateInterval = DateInterval()
        location = CLLocationCoordinate2D()
    }
    
    init(_ location: CLLocationCoordinate2D, _ dateInterval: DateInterval) {
        self.location = location
        self.dateInterval = dateInterval
    }
    
    mutating func setDateInterval(_ interval: DateInterval) {
        self.dateInterval = interval
    }
    
    mutating func setLocation(_ location: CLLocationCoordinate2D) {
        self.location = location
    }
}
