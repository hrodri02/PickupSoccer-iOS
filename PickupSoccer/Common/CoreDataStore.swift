//
//  CoreDataStore.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/10/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import CoreLocation
import CoreData
import UIKit

protocol DataStore {
    func fetchGames(center: CLLocationCoordinate2D,
                    latitudeDelta: CLLocationDegrees,
                    longitudeDelta: CLLocationDegrees,
                    completion: @escaping (Result<[CLLocationCoordinate2D : Game], Error>) -> Void)
    func save(_ game: Game, completion: @escaping (Error?) -> Void)
}

class CoreDataStore: DataStore
{
    let managedObjectContext: NSManagedObjectContext!
    
    init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Failed to get reference to AppDelegate")
        }
        managedObjectContext = appDelegate.persistentContainer.viewContext
    }
    
    deinit {
        print("CoreDataStore deinit")
    }
    
    func fetchGames(center: CLLocationCoordinate2D,
                    latitudeDelta: CLLocationDegrees,
                    longitudeDelta: CLLocationDegrees,
                    completion: @escaping (Result<[CLLocationCoordinate2D : Game], Error>) -> Void)
    {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Game")
        do {
            let managedObjects: [NSManagedObject] = try managedObjectContext.fetch(fetchRequest)
            
            var coordinateToGame = [CLLocationCoordinate2D : Game]()
            for mo in managedObjects {
                let address = mo.value(forKey: "address") as? String
                let locationMO = mo.value(forKey: "location") as? NSManagedObject
                let dateIntervalMO = mo.value(forKey: "dateInterval") as? NSManagedObject
                let latitude = locationMO?.value(forKey: "latitude") as? Double
                let longitude = locationMO?.value(forKey: "longitude") as? Double
                let start = dateIntervalMO?.value(forKey: "start") as? Date
                let end = dateIntervalMO?.value(forKey: "end") as? Date
                let location = CLLocationCoordinate2D(latitude: latitude!,
                                                      longitude: longitude!)
                let dateInterval = DateInterval(start: start!, end: end!)
                let game = Game(location, dateInterval, address ?? "")
                if game.location.latitude > center.latitude - latitudeDelta / 2 &&
                   game.location.latitude < center.latitude + latitudeDelta / 2 &&
                   game.location.longitude > center.longitude - longitudeDelta / 2 &&
                    game.location.longitude < center.longitude + longitudeDelta / 2 {
                    coordinateToGame[location] = game
                }
            }
            completion(Result.success(coordinateToGame))
        }
        catch {
            completion(Result.failure(error))
        }
    }
    
    func save(_ game: Game, completion: @escaping (Error?) -> Void) {
        // 1. get reference to app delegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        // 2. get reference to managed object context
        let managedObjectConext = appDelegate.persistentContainer.viewContext
        // 3. create a game entity
        let gameEntity = NSEntityDescription.entity(forEntityName: "Game", in: managedObjectConext)!
        let locationEntity = NSEntityDescription.entity(forEntityName: "Location", in: managedObjectConext)!
        let dateIntervalEntity = NSEntityDescription.entity(forEntityName: "DateInterval", in: managedObjectConext)!
        // 4. create managed objects
        let gameMO = NSManagedObject(entity: gameEntity, insertInto: managedObjectConext)
        let locationMO = NSManagedObject(entity: locationEntity, insertInto: managedObjectConext)
        let dateIntervalMO = NSManagedObject(entity: dateIntervalEntity, insertInto: managedObjectConext)
        // 5. set properties of game entity
        locationMO.setValue(game.location.latitude, forKey: "latitude")
        locationMO.setValue(game.location.longitude, forKey: "longitude")
        dateIntervalMO.setValue(game.dateInterval.start, forKey: "start")
        dateIntervalMO.setValue(game.dateInterval.end, forKey: "end")
        gameMO.setValue(game.address, forKey: "address")
        gameMO.setValue(locationMO, forKey: "location")
        gameMO.setValue(dateIntervalMO, forKey: "dateInterval")
        // 6. save managed object context
        do {
            try managedObjectConext.save()
        }
        catch {
            completion(error)
        }

    }
}
