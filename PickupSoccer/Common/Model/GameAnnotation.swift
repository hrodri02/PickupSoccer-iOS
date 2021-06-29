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
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var id: String
    
    init(game: Game) {
        self.id = game.id ?? ""
        self.coordinate = game.coordinate
        self.title = game.address
    }
    
    init(coordinate: CLLocationCoordinate2D) {
        self.id = ""
        self.coordinate = coordinate
    }
}
