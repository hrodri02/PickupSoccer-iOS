//
//  DataStore.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/24/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import CoreLocation

protocol DataStore {
    func fetchGames(center: CLLocationCoordinate2D,
                    latitudeDelta: CLLocationDegrees,
                    longitudeDelta: CLLocationDegrees,
                    completion: @escaping (Result<[Game], Error>) -> Void)
    func saveGame(_ address: String,
                  _ location: CLLocationCoordinate2D,
                  _ dateInterval: DateInterval,
                  completion: @escaping (Error?) -> Void)
}
