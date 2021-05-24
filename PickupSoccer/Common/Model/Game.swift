//
//  Game.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/24/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import CoreLocation

protocol Game {
    var address: String? {get set}
    var coordinate: CLLocationCoordinate2D {get set}
    var timeInterval: DateInterval {get set}
}
