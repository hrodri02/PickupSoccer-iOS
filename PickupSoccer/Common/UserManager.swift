//
//  UserManager.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 6/4/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import Foundation

struct UserManager
{
    static let shared = UserManager(dataStore: App.shared.coreDataStore)
    private let dataStore: DataStore
    private var user: User?

    private init(dataStore: DataStore) {
        self.dataStore = dataStore
        let uid = "97F64D03-28FF-4138-98B9-FA1F69E08CAD"
        
        self.dataStore.fetchUser(with: uid) { (result) in
            switch result {
            case .success(let userMO):
                self.user = userMO
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    public func getUser() -> User? {
        return user
    }
}
