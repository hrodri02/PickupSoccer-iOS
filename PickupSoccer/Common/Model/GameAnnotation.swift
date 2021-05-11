//
//  GameAnnotation.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 2/14/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import Foundation
import MapKit

class GameAnnotation: NSObject, MKAnnotation
{
    var game: Game?
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(game: Game) {
        self.game = game
        coordinate = game.location
        title = game.address
    }
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
