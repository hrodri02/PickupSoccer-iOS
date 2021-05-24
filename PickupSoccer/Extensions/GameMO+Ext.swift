//
//  GameMO+Ext.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/24/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import CoreLocation

extension GameMO: Game
{
    var coordinate: CLLocationCoordinate2D {
        get {
            if let location = self.location {
                return CLLocationCoordinate2D(latitude: location.latitude,
                                              longitude: location.longitude)
            }
            else {
                assertionFailure("location is nil")
                return CLLocationCoordinate2D()
            }
        }
        set {
            location?.latitude = newValue.latitude
            location?.longitude = newValue.longitude
        }
    }
    
    var timeInterval: DateInterval {
        get {
            if let dateInterval = self.dateInterval,
                let start = dateInterval.start,
                let end = dateInterval.end
            {
                return DateInterval(start: start, end: end)
            }
            else {
                assertionFailure("dateInterval is nil")
                return DateInterval()
            }
        }
        set {
            dateInterval?.start = newValue.start
            dateInterval?.end = newValue.end
        }
    }
}
