//
//  GamesDataManager.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/10/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import CoreLocation
import CoreData

class GamesDataManager
{
    var coreDataStore: CoreDataStore?
    
    deinit {
        print("GamesDataManager deinit")
    }
    
    func fetchGames(center: CLLocationCoordinate2D,
                    latitudeDelta: CLLocationDegrees,
                    longitudeDelta: CLLocationDegrees,
                    completion: @escaping (Result<[String : Game], Error>) -> Void)
    {
        coreDataStore?.fetchManagedObjects(entityName: "Game", completion: { (result) in
            switch result {
            case .success(let managedObjects):
                var coordinateToGame: [String : Game] = [:]
                for mo in managedObjects {
                    let address = mo.value(forKey: "address") as? String
                    let locationMO = mo.value(forKey: "location") as? NSManagedObject
                    let dateIntervalMO = mo.value(forKey: "dateInterval") as? NSManagedObject
                    let latitude = locationMO?.value(forKey: "latitude") as? Double
                    let longitude = locationMO?.value(forKey: "longitude") as? Double
                    let start = dateIntervalMO?.value(forKey: "start") as? Date
                    let end = dateIntervalMO?.value(forKey: "end") as? Date
                    let key = "lat=\(latitude!), lon=\(longitude!)"
                    let location = CLLocationCoordinate2D(latitude: latitude!,
                                                          longitude: longitude!)
                    let dateInterval = DateInterval(start: start!, end: end!)
                    let game = Game(location, dateInterval, address ?? "")
                    if game.location.latitude > center.latitude - latitudeDelta / 2 &&
                       game.location.latitude < center.latitude + latitudeDelta / 2 &&
                       game.location.longitude > center.longitude - longitudeDelta / 2 &&
                        game.location.longitude < center.longitude + longitudeDelta / 2 {
                        coordinateToGame[key] = game
                    }
                    completion(.success(coordinateToGame))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
}
