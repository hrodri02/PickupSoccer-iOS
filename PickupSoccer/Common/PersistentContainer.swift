//
//  PersistentContainer.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 4/23/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import CoreData

class PersistentContainer: NSPersistentContainer {
    func saveContext(backgroundContext: NSManagedObjectContext? = nil) {
        let context = backgroundContext ?? viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch let error as NSError {
            print("Error: \(error), \(error.userInfo)")
        }
    }
}
