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
    var gameViewModel: GameViewModel?
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(gameViewModel: GameViewModel, coordinate: CLLocationCoordinate2D) {
        self.gameViewModel = gameViewModel
        self.coordinate = coordinate
        self.title = gameViewModel.address
    }
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
