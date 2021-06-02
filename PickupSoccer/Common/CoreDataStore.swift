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
        let predicateFormat = "location.latitude > %f AND location.latitude < %f AND location.longitude > %f AND location.longitude < %f"
        fetchRequest.predicate = NSPredicate(format: predicateFormat,
                                             center.latitude - latitudeDelta / 2,
                                             center.latitude + latitudeDelta / 2,
                                             center.longitude - longitudeDelta / 2,
                                             center.longitude + longitudeDelta / 2)
        do {
            let gamesInRegion: [GameMO] = try managedObjectContext.fetch(fetchRequest) as! [GameMO]
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
        // 3. create a game entity
        guard let gameEntity = NSEntityDescription.entity(forEntityName: "Game", in: managedObjectContext),
            let locationEntity = NSEntityDescription.entity(forEntityName: "Location", in: managedObjectContext),
            let dateIntervalEntity = NSEntityDescription.entity(forEntityName: "DateInterval", in: managedObjectContext) else
        {
            fatalError("Failed to create entity descriptions for Game, Location, and DateInterval entities.")
        }
        
        // 4. create managed objects
        let gameMO = NSManagedObject(entity: gameEntity, insertInto: managedObjectContext) as! GameMO
        let locationMO = NSManagedObject(entity: locationEntity, insertInto: managedObjectContext) as! LocationMO
        let dateIntervalMO = NSManagedObject(entity: dateIntervalEntity, insertInto: managedObjectContext) as! DateIntervalMO
        
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
            try managedObjectContext.save()
        }
        catch {
            completion(error)
        }
    }
}
