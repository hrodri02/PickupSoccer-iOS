//
//  GamesInteractor.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 4/20/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import CoreLocation
import UIKit
import CoreData

class GamesInteractor: GamesPresenterToGamesInteractor {
    weak var presenter: GamesInteractorToGamesPresenter?
    
    deinit {
        print("Games Interactor \(#function)")
    }
    
    func fetchGames(center: CLLocationCoordinate2D,
                    latitudeDelta: CLLocationDegrees,
                    longitudeDelta: CLLocationDegrees)
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Game")
        
        do {
            let managedObjects: [NSManagedObject] = try managedObjectContext.fetch(fetchRequest)
            var coordinateToGame: [String : Game] = [:]
            for mo in managedObjects {
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
                let game = Game(location, dateInterval)
                if game.location.latitude > center.latitude - latitudeDelta / 2 &&
                   game.location.latitude < center.latitude + latitudeDelta / 2 &&
                   game.location.longitude > center.longitude - longitudeDelta / 2 &&
                    game.location.longitude < center.longitude + longitudeDelta / 2 {
                    coordinateToGame[key] = game
                }
            }
            presenter?.onFetchGamesSuccess(coordinateToGame)
        }
        catch {
            print("Failed to fetch games from CoreData")
        }
    }
}
