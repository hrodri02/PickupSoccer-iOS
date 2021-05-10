//
//  CoreDataStore.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/10/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import CoreData
import UIKit

class CoreDataStore
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
    
    func fetchManagedObjects(entityName: String, completion: @escaping (Result<[NSManagedObject], Error>) -> Void) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        
        do {
            let managedObjects: [NSManagedObject] = try managedObjectContext.fetch(fetchRequest)
            completion(Result.success(managedObjects))
        }
        catch {
            completion(Result.failure(error))
        }
    }
}
