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
                    completion: @escaping (Result<[Game], Error>) -> Void)
    {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Game")
        do {
            let managedObjects: [GameMO] = try managedObjectContext.fetch(fetchRequest) as! [GameMO]
            
            var gamesInRegion = [GameMO]()
            for mo in managedObjects {
                if let location = mo.location {
                    if location.latitude > center.latitude - latitudeDelta / 2 &&
                       location.latitude < center.latitude + latitudeDelta / 2 &&
                       location.longitude > center.longitude - longitudeDelta / 2 &&
                       location.longitude < center.longitude + longitudeDelta / 2
                    {
                        gamesInRegion.append(mo)
                    }
                }
                
            }
            completion(Result.success(gamesInRegion))
        }
        catch {
            completion(Result.failure(error))
        }
    }
    
    func saveGame(_ address: String,
                  _ location: CLLocationCoordinate2D,
                  _ dateInterval: DateInterval,
                  completion: @escaping (Error?) -> Void)
    {
        // 1. get reference to app delegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        // 2. get reference to managed object context
        let managedObjectConext = appDelegate.persistentContainer.viewContext
        // 3. create a game entity
        let gameEntity = NSEntityDescription.entity(forEntityName: "Game", in: managedObjectConext)!
        let locationEntity = NSEntityDescription.entity(forEntityName: "Location", in: managedObjectConext)!
        let dateIntervalEntity = NSEntityDescription.entity(forEntityName: "DateInterval", in: managedObjectConext)!
        // 4. create managed objects
        let gameMO = NSManagedObject(entity: gameEntity, insertInto: managedObjectConext) as! GameMO
        let locationMO = NSManagedObject(entity: locationEntity, insertInto: managedObjectConext) as! LocationMO
        let dateIntervalMO = NSManagedObject(entity: dateIntervalEntity, insertInto: managedObjectConext) as! DateIntervalMO
        
        // 5. set properties of game entity
        locationMO.latitude = location.latitude
        locationMO.longitude = location.longitude
        dateIntervalMO.start = dateInterval.start
        dateIntervalMO.end = dateInterval.end
        gameMO.address = address
        gameMO.location = locationMO
        gameMO.dateInterval = dateIntervalMO
        
        // 6. save managed object context
        do {
            try managedObjectConext.save()
        }
        catch {
            completion(error)
        }

    }
}
