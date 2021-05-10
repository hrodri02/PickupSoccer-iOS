//
//  App.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 3/17/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import Foundation

class App {
    static let shared = App()
    
    var userLocationService: UserLocationService {
        return UserLocationService()
    }
    
    var coreDataStore: CoreDataStore {
        return CoreDataStore()
    }
    
    private init() {
        
    }
}
