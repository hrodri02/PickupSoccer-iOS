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
    var address: String
    var location: CLLocationCoordinate2D
    var dateInterval: DateInterval
    
    init() {
        address = ""
        dateInterval = DateInterval()
        location = CLLocationCoordinate2D()
    }
    
    init(_ location: CLLocationCoordinate2D, _ dateInterval: DateInterval, _ address: String = "") {
        self.address = address
        self.location = location
        self.dateInterval = dateInterval
    }
    
    mutating func setAddress(_ address: String) {
        self.address = address
    }
    
    mutating func setDateInterval(_ interval: DateInterval) {
        self.dateInterval = interval
    }
    
    mutating func setLocation(_ location: CLLocationCoordinate2D) {
        self.location = location
    }
}
